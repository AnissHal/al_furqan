enum Encouragement {
  special, // anta momayz
  keepFocus, // a7res 3la maynfa3k
  successSoon, // naja7 9arib
  makeEffort, // la ta3jaz
  godBless, // wafa9k Allah
  greatEffort, // majhood 3adim
  progress; // ta9adm kabir

  @override
  String toString() {
    return switch (this) {
      Encouragement.special => "special",
      Encouragement.keepFocus => "keepFocus",
      Encouragement.successSoon => "successSoon",
      Encouragement.makeEffort => "makeEffort",
      Encouragement.godBless => "godBless",
      Encouragement.greatEffort => "greatEffort",
      Encouragement.progress => "progress",
    };
  }

  static Encouragement fromString(String encouragement) {
    switch (encouragement) {
      case "special":
        return Encouragement.special;
      case "keepFocus":
        return Encouragement.keepFocus;
      case "successSoon":
        return Encouragement.successSoon;
      case "makeEffort":
        return Encouragement.makeEffort;
      case "godBless":
        return Encouragement.godBless;
      case "greatEffort":
        return Encouragement.greatEffort;
      case "progress":
        return Encouragement.progress;
      default:
        return Encouragement.successSoon;
    }
  }
}

enum Behaviour {
  studious, // mo2adeb
  talkative, // katir kalem
  unstudious, // yal3b f el ders
  notPraying; // lam yosali

  @override
  String toString() {
    return switch (this) {
      Behaviour.studious => "studious",
      Behaviour.talkative => "talkative",
      Behaviour.unstudious => "unstudious",
      Behaviour.notPraying => "notPraying",
    };
  }

  static Behaviour fromString(String behaviour) {
    switch (behaviour) {
      case "studious":
        return Behaviour.studious;
      case "talkative":
        return Behaviour.talkative;
      case "unstudious":
        return Behaviour.unstudious;
      case "notPraying":
        return Behaviour.notPraying;
      default:
        return Behaviour.studious;
    }
  }
}
