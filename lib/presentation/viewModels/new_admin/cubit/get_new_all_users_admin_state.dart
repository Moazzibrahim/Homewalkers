// import 'package:homewalkers_app/data/models/new_admin_users_model.dart';
// import 'package:equatable/equatable.dart';

// // --- Cubit State ---
// // هذا الجزء يمثل الحالات المختلفة التي يمكن أن يكون عليها الـ Cubit
// // It is equivalent to the content of 'part 'get_new_all_users_admin_state.dart';'

// abstract class GetNewAllUsersAdminState extends Equatable {
//   const GetNewAllUsersAdminState();

//   @override
//   List<Object> get props => [];
// }

// class GetNewAllUsersAdminInitial extends GetNewAllUsersAdminState {}

// class GetNewAllUsersAdminLoading extends GetNewAllUsersAdminState {}

// class GetNewAllUsersAdminSuccess extends GetNewAllUsersAdminState {
//   final NewAdminUsersModel allUsersModel;

//   const GetNewAllUsersAdminSuccess(this.allUsersModel);

//   @override
//   List<Object> get props => [allUsersModel];
// }

// class GetNewAllUsersAdminFailure extends GetNewAllUsersAdminState {
//   final String errorMessage;

//   const GetNewAllUsersAdminFailure(this.errorMessage);

//   @override
//   List<Object> get props => [errorMessage];
// }