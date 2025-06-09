import 'package:equatable/equatable.dart';
import 'package:homewalkers_app/data/models/channel_model.dart';

abstract class ChannelState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ChannelInitial extends ChannelState {}

class ChannelLoading extends ChannelState {}

class ChannelLoaded extends ChannelState {
  final ChannelModelresponse channelResponse;

  ChannelLoaded(this.channelResponse);

  @override
  List<Object?> get props => [channelResponse];
}

class ChannelError extends ChannelState {
  final String message;

  ChannelError(this.message);

  @override
  List<Object?> get props => [message];
}
