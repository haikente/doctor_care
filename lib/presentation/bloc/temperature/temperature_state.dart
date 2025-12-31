part of 'temperature_cubit.dart';

abstract class TemperatureState extends Equatable {
  const TemperatureState();

  @override
  List<Object> get props => [];
}

class TemperatureInitial extends TemperatureState {}
class TemperatureLoading extends TemperatureState {}
class TemperatureLoaded extends TemperatureState {
  final List<Temperature> temperatures;

  const TemperatureLoaded(this.temperatures);

  @override
  List<Object> get props => [temperatures];
}
class TemperatureError extends TemperatureState {
  final String message;

  const TemperatureError(this.message);

  @override
  List<Object> get props => [message];
}
