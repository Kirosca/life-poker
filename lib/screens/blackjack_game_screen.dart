import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class BlackjackGameScreen extends StatefulWidget {
  const BlackjackGameScreen({super.key});

  @override
  State<BlackjackGameScreen> createState() => _BlackjackGameScreenState();
}

class _CardModel {
  final String suit;
  final String rank;
  final int value;
  final Color color;

  _CardModel(this.suit, this.rank, this.value, this.color);
}

class _BlackjackGameScreenState extends State<BlackjackGameScreen> {
  int _chips = 500;
  final int _currentBet = 50;
  bool _isPlaying = false;
  String _gameResult = '';
  Color _resultColor = Colors.white;

  List<_CardModel> _playerHand = [];
  List<_CardModel> _dealerHand = [];
  bool _dealerRevealed = false;

  final List<String> _suits = ['♠', '♥', '♣', '♦'];
  final List<String> _ranks = ['A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K'];

  _CardModel _drawRandomCard() {
    final random = Random();
    final suit = _suits[random.nextInt(_suits.length)];
    final rankIndex = random.nextInt(_ranks.length);
    final rank = _ranks[rankIndex];
    int val = rankIndex + 1;
    if (val > 10) val = 10;
    if (rank == 'A') val = 11;
    final color = (suit == '♥' || suit == '♦') ? const Color(0xFFF43F5E) : const Color(0xFF64748B);
    return _CardModel(suit, rank, val, color);
  }

  int _calculateHand(List<_CardModel> hand) {
    int total = hand.fold(0, (sum, c) => sum + c.value);
    int aces = hand.where((c) => c.rank == 'A').length;
    while (total > 21 && aces > 0) {
      total -= 10;
      aces--;
    }
    return total;
  }

  void _startNewGame() {
    if (_chips < _currentBet) {
      _chips += 200; // 破产救济
    }
    setState(() {
      _isPlaying = true;
      _gameResult = '';
      _dealerRevealed = false;
      _playerHand = [_drawRandomCard(), _drawRandomCard()];
      _dealerHand = [_drawRandomCard(), _drawRandomCard()];

      final playerTotal = _calculateHand(_playerHand);
      if (playerTotal == 21) {
        _stand();
      }
    });
  }

  void _hit() {
    setState(() {
      _playerHand.add(_drawRandomCard());
      final total = _calculateHand(_playerHand);
      if (total > 21) {
        _endGame('💥 爆牌 (Bust)！输掉本局', Colors.redAccent, false);
      } else if (total == 21) {
        _stand();
      }
    });
  }

  void _stand() {
    setState(() {
      _dealerRevealed = true;
      // Dealer AI: draws until >= 17
      while (_calculateHand(_dealerHand) < 17) {
        _dealerHand.add(_drawRandomCard());
      }

      final playerTotal = _calculateHand(_playerHand);
      final dealerTotal = _calculateHand(_dealerHand);

      if (dealerTotal > 21) {
        _endGame('🎉 庄家爆牌！你赢了！', const Color(0xFF10B981), true);
      } else if (playerTotal > dealerTotal) {
        _endGame('👑 绝佳手牌 ($playerTotal vs $dealerTotal)！获胜！', const Color(0xFF10B981), true);
      } else if (playerTotal == dealerTotal) {
        _endGame('🤝 平局 (Push)！返还筹码', Colors.amber, null);
      } else {
        _endGame('庄家更大 ($dealerTotal vs $playerTotal)，惜败！', Colors.redAccent, false);
      }
    });
  }

  void _endGame(String message, Color color, bool? won) {
    _isPlaying = false;
    _gameResult = message;
    _resultColor = color;
    _dealerRevealed = true;
    if (won == true) {
      _chips += _currentBet;
    } else if (won == false) {
      _chips -= _currentBet;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final playerTotal = _calculateHand(_playerHand);
    final dealerTotal = _dealerRevealed
        ? _calculateHand(_dealerHand)
        : (_dealerHand.isNotEmpty ? _dealerHand[0].value : 0);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(LucideIcons.gamepad2, size: 20),
            SizedBox(width: 8),
            Text('Blackjack 21点休闲小游戏', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ShadBadge.secondary(
              child: Row(
                children: [
                  const Icon(LucideIcons.coins, size: 14, color: Colors.amber),
                  const SizedBox(width: 4),
                  Text('筹码: $_chips', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Dealer Section
              ShadCard(
                padding: const EdgeInsets.all(16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('庄家手牌 (Dealer)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ShadBadge.outline(
                      child: Text(_dealerRevealed ? '$dealerTotal 点' : '暗牌 1 张'),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _dealerHand.isEmpty
                        ? [const Text('等待发牌...')]
                        : List.generate(_dealerHand.length, (i) {
                            if (i == 1 && !_dealerRevealed) {
                              return _buildCardHidden(theme);
                            }
                            return _buildCardWidget(_dealerHand[i]);
                          }),
                  ),
                ),
              ),

              const Spacer(),

              // Game result message
              if (_gameResult.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _resultColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _resultColor),
                  ),
                  child: Text(
                    _gameResult,
                    style: TextStyle(
                      color: _resultColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Player Section
              ShadCard(
                padding: const EdgeInsets.all(16),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('你的手牌 (Player)', style: TextStyle(fontWeight: FontWeight.bold)),
                    ShadBadge.secondary(
                      child: Text('$playerTotal 点', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _playerHand.isEmpty
                        ? [const Text('点击下方按钮发牌开局')]
                        : _playerHand.map((c) => _buildCardWidget(c)).toList(),
                  ),
                ),
              ),

              const Spacer(),

              // Controls
              if (!_isPlaying)
                ShadButton(
                  width: double.infinity,
                  leading: const Icon(LucideIcons.play, size: 16),
                  onPressed: _startNewGame,
                  child: Text(_playerHand.isEmpty ? '发牌开局 (下注 $_currentBet 筹码)' : '再来一局 (下注 $_currentBet 筹码)'),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: ShadButton.outline(
                        leading: const Icon(LucideIcons.plusCircle, size: 16),
                        onPressed: _hit,
                        child: const Text('Hit (要牌)'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ShadButton(
                        leading: const Icon(LucideIcons.hand, size: 16),
                        onPressed: _stand,
                        child: const Text('Stand (停牌)'),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardWidget(_CardModel card) {
    return Container(
      width: 60,
      height: 84,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              card.rank,
              style: TextStyle(
                color: card.color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            card.suit,
            style: TextStyle(color: card.color, fontSize: 20),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(
              card.rank,
              style: TextStyle(
                color: card.color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardHidden(ShadThemeData theme) {
    return Container(
      width: 60,
      height: 84,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.muted,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.border, width: 1.5),
      ),
      child: Center(
        child: Icon(LucideIcons.helpCircle, color: theme.colorScheme.mutedForeground, size: 24),
      ),
    );
  }
}
