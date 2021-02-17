class Progress {
  final int sent;
  final int total;

  double get percentage => sent / total;

  const Progress(this.sent, this.total);
}
