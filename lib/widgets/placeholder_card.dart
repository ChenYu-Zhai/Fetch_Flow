// // lib/widgets/staggered_build_card.dart (建议重命名)

// import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';

// class StaggeredBuildCard extends StatefulWidget {
//   final Widget child;
//   final double aspectRatio;
//   final int buildSteps;
//   final bool shouldStartBuilding;
//   final Widget? placeholder;
//   const StaggeredBuildCard({
//     super.key,
//     required this.child,
//     required this.aspectRatio,
//     this.buildSteps = 2,
//     this.shouldStartBuilding = true, 
//     this.placeholder,
//   });

//   @override
//   State<StaggeredBuildCard> createState() => _StaggeredBuildCardState();
// }

// class _StaggeredBuildCardState extends State<StaggeredBuildCard> {
//   int _currentBuildStep = 0;
//   bool _hasStarted = false;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.shouldStartBuilding) {
//       _startBuilding();
//     }
//   }

//   @override
//   void didUpdateWidget(covariant StaggeredBuildCard oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.shouldStartBuilding && !oldWidget.shouldStartBuilding) {
//       _startBuilding();
//     }
//   }

//   void _startBuilding() {
//     if (_hasStarted) return;
//     _hasStarted = true;
//     _scheduleNextStep();
//   }

//   void _scheduleNextStep() {
//     SchedulerBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;
//       setState(() {
//         _currentBuildStep++;
//       });
//       if (_currentBuildStep < widget.buildSteps) {
//         _scheduleNextStep();
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Theme.of(context).canvasColor,
//         borderRadius: BorderRadius.zero,
//       ),
//       child: AspectRatio(
//         aspectRatio: widget.aspectRatio,
//         child: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 100),
//           child: _buildContentForStep(),
//         ),
//       ),
//     );
//   }

//   Widget _buildContentForStep() {
//     if (_currentBuildStep >= widget.buildSteps) {
//       return KeyedSubtree(
//         key: const ValueKey('final_child'),
//         child: widget.child,
//       );
//     }

//     if (widget.placeholder != null) {
//       return Container(
//         child: KeyedSubtree(
//           key: const ValueKey('custom_placeholder'),
//           child: widget.placeholder!,
//         ),
//       );
//     }

//     if (_currentBuildStep >= 1) {
//       return Container(
//         key: const ValueKey('skeleton'),
//         color: Theme.of(context).canvasColor.withOpacity(0.5),
//         child: Center(
//           child: Icon(
//             Icons.image_outlined,
//             color: Colors.grey.shade400,
//             size: 40,
//           ),
//         ),
//       );
//     }

//     return Container(
//       key: const ValueKey('placeholder'),
//       color: Colors.grey.shade300,
//     );
//   }
// }
