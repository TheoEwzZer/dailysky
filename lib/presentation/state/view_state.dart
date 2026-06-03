/// État générique d'un écran piloté par un ViewModel : chargement, succès
/// (avec données) ou échec (avec message). Le type scellé permet un `switch`
/// exhaustif côté widget.
sealed class ViewState<T> {
  const ViewState();
}

class LoadingState<T> extends ViewState<T> {
  const LoadingState();
}

class SuccessState<T> extends ViewState<T> {
  const SuccessState(this.data);
  final T data;
}

class FailureState<T> extends ViewState<T> {
  const FailureState(this.message);
  final String message;
}
