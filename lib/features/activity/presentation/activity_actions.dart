import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../inventory/presentation/cubit/inventory_cubit.dart';
import '../domain/entities/activity.dart';
import 'cubit/activity_cubit.dart';
import 'pages/add_activity_page.dart';

/// Mở màn hình chỉnh sửa một hoạt động.
void openEditActivity(BuildContext context, Activity activity) {
  final cubit = context.read<ActivityCubit>();
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: AddActivityPage(
          type: activity.type,
          babyId: activity.babyId,
          existing: activity,
        ),
      ),
    ),
  );
}

/// Xoá một hoạt động; nếu là thay tã thì hoàn lại 1 bỉm vào kho.
Future<void> deleteActivity(BuildContext context, Activity activity) async {
  final activityCubit = context.read<ActivityCubit>();
  if (activity.type == ActivityType.diaper) {
    await context.read<InventoryCubit>().removeDiaperFor(
          activityId: activity.id,
          babyId: activity.babyId,
        );
  }
  await activityCubit.remove(activity.id);
}
