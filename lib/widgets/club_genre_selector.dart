import 'package:clubship/colors.dart';
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
    // Update local state when widget.selectedTags changes
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
    final List<String> displayedGenres = widget.isEditable ? clubGenres : selectedGenres.toList();

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: displayedGenres.map((genre) {
        final isSelected = selectedGenres.contains(genre);
        return ChoiceChip(
          showCheckmark: false,
          label: Text(
            genre,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          selected: isSelected,
          selectedColor: ColorPallete.cardColor,
          backgroundColor: Colors.grey[300],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onSelected: widget.isEditable ? (_) => _toggleSelection(genre) : (_){},
        );
      }).toList(),
    );
  }
}
