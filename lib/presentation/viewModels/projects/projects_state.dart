part of 'projects_cubit.dart';

@immutable
sealed class ProjectsState {}

/// الحالة الابتدائية
final class ProjectsInitial extends ProjectsState {}

/// حالة تحميل البيانات
final class ProjectsLoading extends ProjectsState {}

/// حالة النجاح: يتم تمرير نموذج المشاريع
final class ProjectsSuccess extends ProjectsState {
  final ProjectsModel projectsModel;

  ProjectsSuccess({required this.projectsModel});
}

/// حالة الخطأ: يتم تمرير رسالة الخطأ
final class ProjectsError extends ProjectsState {
  final String error;

  ProjectsError({required this.error});
}
