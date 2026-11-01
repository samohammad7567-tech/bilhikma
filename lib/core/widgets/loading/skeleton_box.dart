import 'package:bilhikma/core/widgets/app_skeleton_box.dart';

class SkeletonBox extends AppSkeletonBox {
  const SkeletonBox({
    super.key,
    double height = 16,
    double? width,
    double? radius,
    bool isCircular = false,
  }) : super(height: height, width: width, radius: radius, isCircular: isCircular);
}
