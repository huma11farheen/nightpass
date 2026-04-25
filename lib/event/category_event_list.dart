import 'package:clubship/event/event_card.dart';
import 'package:clubship/event/event_view_model.dart';
import 'package:clubship/event/providers/get_events_by_category.dart';
import 'package:clubship/utils/helpers.dart';
import 'package:clubship/utils/typography.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CategoryEventListParams {
  CategoryEventListParams({
    required this.eventTypeId,
    required this.eventName,
  });

  final String eventTypeId;
  final String eventName;
}

class CategoryDrinkList extends ConsumerWidget {
  const CategoryDrinkList({
    super.key,
    required this.params,
  });

  final CategoryEventListParams params;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<EventViewModel>> drinks = ref.watch(
      getEventsByCategoryProvider(params.eventTypeId),
    );

    return drinks.when(
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeletonizer(
              effect: ShimmerEffect(
                baseColor: Colors.grey[700]!,
                highlightColor: Colors.grey[500]!,
                duration: const Duration(milliseconds: 800),
              ),
              enabled: true,
              child: Text(
                params.eventName,
                style: Theme.of(context).labelLarge,
              ).pad.bottom.p24,
            ),
            const Skeletonizer(
              effect: ShimmerEffect(
                highlightColor: Colors.black,
                duration: Duration(milliseconds: 800),
              ),
              enabled: true,
              child: SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator()),
              ),
            ),
          ],
        ),
      ),
      error: (error, stackTrace) => const Text('Error getting drinks'),
      data: (event) {
        final eventList = event
            .where((drink) => drink.category.contains(params.eventName))
            .toList();

        return Scaffold(
          appBar: AppBar(
            title: Text(params.eventName),
          ),
          body: event.isNotEmpty
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: eventList.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // Number of columns
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 3 / 5, // Adjust as needed
                        ),
                        itemBuilder: (context, index) {
                          final drink = eventList[index];
                          return EventCard(
                            eventItem: drink,
                            onTap: () {},
                          );
                        },
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: SizedBox(
                    child: Text('No Events registered'),
                  ),
                ),
        );
      },
    );
  }
}
