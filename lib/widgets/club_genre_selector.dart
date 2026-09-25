import 'package:clubship/design/brutal.dart';
import 'package:flutter/material.dart';

class ClubGenreSelector extends StatefulWidget {
  final List<String> selectedGenres;
  final Function(List<String>) onSelectionChanged;
  final bool isEditable;

  const ClubGenreSelector({
    super.key,
    required this.selectedGenres,
    required this.onSelectionChanged,
    this.isEditable = true,
  });

  @override
  State<ClubGenreSelector> createState() => _ClubGenreSelectorState();
}

class _ClubGenreSelectorState extends State<ClubGenreSelector> {
  late List<String> selectedGenres;

  @override
  void initState() {
    super.initState();
    selectedGenres = List<String>.from(widget.selectedGenres);
  }

  @override
  void didUpdateWidget(covariant ClubGenreSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedGenres != oldWidget.selectedGenres) {
      setState(() {
        selectedGenres = List<String>.from(widget.selectedGenres);
      });
    }
  }

  void _toggleSelection(String genre) {
    setState(() {
      if (selectedGenres.contains(genre)) {
        selectedGenres.remove(genre);
      } else {
        selectedGenres.add(genre);
      }
      widget.onSelectionChanged(selectedGenres);
    });
  }

  final List<String> clubGenres = [
    "Nightclub",
    "Bar & Lounge",
    "Live Music",
    "Jazz Club",
    "Karaoke",
    "Comedy Club",
    "Dance Club",
    "Sports Bar",
    "Theater",
    "Electronic",
    "Rock & Metal",
    "Hip-Hop",
    "Latin",
    "Country",
    "Rooftop Bar",
    "LGBTQ+ Friendly",
    "Speakeasy",
    "Pop Culture",
    "Private Members Club",
    "Cultural Club",
  ];

  @override
  Widget build(BuildContext context) {
    final List<String> displayedGenres =
        widget.isEditable ? clubGenres : selectedGenres.toList();

    return Wrap(
      spacing: 6.0,
      runSpacing: 6.0,
      children: displayedGenres.map((genre) {
        final isSelected = selectedGenres.contains(genre);
        return GestureDetector(
          onTap: widget.isEditable ? () => _toggleSelection(genre) : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected
                  ? Brutal.magenta.withValues(alpha: 0.15)
                  : Brutal.elevated,
              border: Border.all(
                color: isSelected ? Brutal.magenta : Brutal.hairlineColor,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Text(
              genre,
              style: Brutal.label(
                size: 11,
                color: isSelected ? Brutal.magenta : Brutal.dim,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
