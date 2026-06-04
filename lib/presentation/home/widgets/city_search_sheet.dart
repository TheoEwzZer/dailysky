import 'package:flutter/material.dart';

/// Feuille modale de recherche de ville. La recherche est effectuée
/// directement dans la feuille : elle affiche un indicateur de chargement
/// pendant l'appel et montre l'erreur inline si la ville est introuvable.
/// La feuille ne se ferme qu'en cas de succès ou d'annulation.
class CitySearchSheet extends StatefulWidget {
  const CitySearchSheet({super.key, required this.onSearch});

  /// Callback appelé avec le nom de la ville saisie.
  /// Retourne `null` si la recherche a réussi, ou un message d'erreur.
  final Future<String?> Function(String city) onSearch;

  /// Ouvre la feuille. [onSearch] est appelé à chaque soumission.
  static Future<void> show(
    BuildContext context,
    Future<String?> Function(String city) onSearch,
  ) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => CitySearchSheet(onSearch: onSearch),
    );
  }

  @override
  State<CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<CitySearchSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final value = _controller.text.trim();
    if (value.isEmpty) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final error = await widget.onSearch(value);

    if (!mounted) return;

    if (error == null) {
      // Succès : on ferme la feuille.
      Navigator.of(context).pop();
    } else {
      // Échec : on reste ouvert et on affiche l'erreur sous le champ.
      setState(() {
        _isLoading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        4,
        20,
        20 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rechercher une ville',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            enabled: !_isLoading,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Ex. Paris, Lyon, Tokyo…',
              prefixIcon: const Icon(Icons.search_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              errorText: _error,
              errorMaxLines: 2,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isLoading ? null : _submit,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Voir la météo'),
            ),
          ),
        ],
      ),
    );
  }
}
