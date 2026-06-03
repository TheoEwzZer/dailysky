/// Helpers de parsing JSON tolérants : ne lèvent jamais d'exception sur un
/// champ manquant ou d'un type inattendu, ils renvoient une valeur de repli.
double asDouble(dynamic value, [double fallback = 0]) =>
    value is num ? value.toDouble() : fallback;

int asInt(dynamic value, [int fallback = 0]) =>
    value is num ? value.toInt() : fallback;
