import 'package:flutter/material.dart';

class FloorSelector extends StatefulWidget {
  final String initialFloor;
  final ValueChanged<String> onFloorChanged;

  const FloorSelector({
    super.key,
    required this.initialFloor,
    required this.onFloorChanged,
  });

  @override
  State<FloorSelector> createState() => _FloorSelectorState();
}

class _FloorSelectorState extends State<FloorSelector> {
  late String _currentFloor;
  bool _isCustomMode = false;
  late TextEditingController _textController;

  final List<String> _commonFloors = ['B4', 'B3', 'B2', 'B1', '1F', '2F', '3F', '4F'];
  static const Color _darkInput = Color(0xFF1E2532);
  static const Color _brandGreen = Color(0xFF34D399);

  @override
  void initState() {
    super.initState();
    _currentFloor = widget.initialFloor;
    _textController = TextEditingController(text: widget.initialFloor);
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _updateFloor(String floor) {
    setState(() {
      _currentFloor = floor;
      _textController.text = floor;
    });
    widget.onFloorChanged(floor);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.apartment, size: 14, color: _brandGreen),
              const SizedBox(width: 6),
              const Text(
                '주차 층',
                style: TextStyle(
                  color: _brandGreen,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
        AnimatedCrossFade(
          firstChild: _buildButtonList(),
          secondChild: _buildCustomInput(),
          crossFadeState:
              _isCustomMode ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 300),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }

  Widget _buildButtonList() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _commonFloors.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (index == _commonFloors.length) {
            return _buildOtherButton();
          }
          final floor = _commonFloors[index];
          final isSelected = _currentFloor == floor;
          return GestureDetector(
            onTap: () => _updateFloor(floor),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected ? _brandGreen : _darkInput,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? _brandGreen : Colors.white.withOpacity(0.05),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: _brandGreen.withOpacity(0.3),
                          blurRadius: 15,
                        ),
                      ]
                    : [],
              ),
              alignment: Alignment.center,
              child: Text(
                floor,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.grey[400],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOtherButton() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isCustomMode = true;
          if (_commonFloors.contains(_currentFloor)) {
            _textController.clear();
            _currentFloor = '';
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 48,
        decoration: BoxDecoration(
          color: _darkInput,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.keyboard, size: 16, color: Colors.grey[400]),
            const SizedBox(width: 8),
            Text(
              '기타 입력',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomInput() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => setState(() => _isCustomMode = false),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _darkInput,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Icon(Icons.chevron_left, color: Colors.grey[400]),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: _darkInput,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _brandGreen.withOpacity(0.5)),
            ),
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                TextField(
                  controller: _textController,
                  autofocus: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  cursorColor: _brandGreen,
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.only(left: 16, right: 70, bottom: 4),
                    border: InputBorder.none,
                    hintText: '예: B5, 7F...',
                    hintStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  onChanged: (value) {
                    final formatted = value.toUpperCase();
                    _textController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                    widget.onFloorChanged(formatted);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _brandGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _brandGreen.withOpacity(0.2)),
                    ),
                    child: const Text(
                      '수기 입력',
                      style: TextStyle(
                        color: _brandGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

