import 'package:bloc/bloc.dart';
import 'package:homewalkers_app/data/data_sources/projects_api_service.dart';
import 'package:meta/meta.dart';
import 'package:homewalkers_app/data/models/projects_model.dart';

part 'projects_state.dart';

class ProjectsCubit extends Cubit<ProjectsState> {
  final ProjectsApiService apiService;

  ProjectsCubit(this.apiService) : super(ProjectsInitial());

  Future<void> fetchProjects() async {
    emit(ProjectsLoading());
    try {
      final projects = await apiService.fetchProjects();
      emit(ProjectsSuccess(projectsModel: projects));
    } catch (e) {
      emit(ProjectsError(error: e.toString()));
    }
  }
    Future<void> fetchProjectsInTrash() async {
    emit(ProjectsLoading());
    try {
      final projects = await apiService.fetchProjectsInTrash();
      emit(ProjectsSuccess(projectsModel: projects));
    } catch (e) {
      emit(ProjectsError(error: e.toString()));
    }
  }
}
