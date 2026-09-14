/// North America (incl. Caribbean & Central America) country list used for
/// the Add Customer "Country" dropdown and to pick the phone field's
/// default dial code. `name` is what gets stored/sent to the API (matches
/// the payload shape, e.g. "United States of America"), `iso` is the
/// ISO 3166-1 alpha-2 code used by the phone package's country picker.
class CountryOption {
  final String name;
  final String iso;

  const CountryOption({required this.name, required this.iso});
}

const List<CountryOption> kNorthAmericaCountries = [
  CountryOption(name: 'Canada', iso: 'CA'),
  CountryOption(name: 'Mexico', iso: 'MX'),
  CountryOption(name: 'United States of America', iso: 'US'),
  CountryOption(name: 'Antigua and Barbuda', iso: 'AG'),
  CountryOption(name: 'The Bahamas', iso: 'BS'),
  CountryOption(name: 'Barbados', iso: 'BB'),
  CountryOption(name: 'Cuba', iso: 'CU'),
  CountryOption(name: 'Dominica', iso: 'DM'),
  CountryOption(name: 'Dominican Republic', iso: 'DO'),
  CountryOption(name: 'Grenada', iso: 'GD'),
  CountryOption(name: 'Haiti', iso: 'HT'),
  CountryOption(name: 'Jamaica', iso: 'JM'),
  CountryOption(name: 'Saint Kitts and Nevis', iso: 'KN'),
  CountryOption(name: 'Saint Lucia', iso: 'LC'),
  CountryOption(name: 'Saint Vincent and the Grenadines', iso: 'VC'),
  CountryOption(name: 'Trinidad and Tobago', iso: 'TT'),
  CountryOption(name: 'Belize', iso: 'BZ'),
  CountryOption(name: 'Costa Rica', iso: 'CR'),
  CountryOption(name: 'El Salvador', iso: 'SV'),
  CountryOption(name: 'Guatemala', iso: 'GT'),
  CountryOption(name: 'Honduras', iso: 'HN'),
  CountryOption(name: 'Nicaragua', iso: 'NI'),
  CountryOption(name: 'Panama', iso: 'PA'),
];

/// Default country when the Add Customer form first loads (keeps existing
/// behavior, since states/customers were previously US-only).
const String kDefaultCountryName = 'United States of America';

/// Looks up the ISO alpha-2 code for a country name from
/// [kNorthAmericaCountries]. Falls back to 'US' if not found.
String isoCodeForCountry(String? countryName) {
  return kNorthAmericaCountries
      .firstWhere(
        (c) => c.name == countryName,
        orElse: () => const CountryOption(name: kDefaultCountryName, iso: 'US'),
      )
      .iso;
}