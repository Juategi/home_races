class Competition{
  int id, capacity, numcompetitors, duration;
  double price;
  String name, type, modality, locality, rewards, observations, promoted, timezone, image, organizer;
  DateTime eventdate, maxdate;
  Competition({this.id, this.duration, this.organizer, this.numcompetitors, this.locality, this.image ,this.name, this.price, this.capacity, this.eventdate, this.maxdate, this.modality, this.observations, this.promoted, this.rewards, this.timezone, this.type});
}