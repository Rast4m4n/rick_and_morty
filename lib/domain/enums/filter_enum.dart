enum CharacterStatus {
  alive('Alive'),
  dead('Dead'),
  unknown('Unknown'),
  all('all');

  final String value;
  const CharacterStatus(this.value);
}

enum CharacterGender {
  male('Male'),
  female('Female'),
  unknown('Unknown'),
  all('all');

  final String value;
  const CharacterGender(this.value);
}

enum CharacterSpecies {
  human('Human'),
  humanoid('Humanoid'),
  alien('Alien'),
  unknown('Unknown'),
  mythologicCreature('Mythological Creature'),
  animal('Animal'),
  all('all');

  final String value;
  const CharacterSpecies(this.value);
}
