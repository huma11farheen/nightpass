// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:clubship/event/event_item.dart';
// import 'package:clubship/event/events_detail_page.dart';
// import 'package:flutter/material.dart';
//
// import 'no_image_widget.dart';
//
// class MainEventList extends StatelessWidget {
//   final Function(int) onShopItemTapped;
//   final Function() onFooterButtonTapped;
//   final List<EventItem>? list;
//   final bool showMore;
//
//   const MainEventList({
//     super.key,
//     required this.onShopItemTapped,
//     required this.onFooterButtonTapped,
//     required this.list,
//     this.showMore = true,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (list == null) {
//       return SizedBox();
//     }
//
//     return _buildPagerView(
//       context: context,
//       newShops: list!,
//     );
//   }
//
//   Widget _buildPagerView({
//     required BuildContext context,
//     required List<EventItem> newShops,
//   }) {
//     return Column(
//       children: [
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//                 children: newShops
//                     .map((item) => Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   Navigator.push(
//                                     context,
//                                     MaterialPageRoute(
//                                         builder: (context) =>
//                                             const EventDetailPage(eventItem: ,)),
//                                   );
//                                 },
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(16),
//                                     color: Colors.white,
//                                   ),
//                                   margin: EdgeInsets.only(right: 16),
//                                   height: 140,
//                                   width: 140,
//                                   child: ClipRRect(
//                                     borderRadius: BorderRadius.circular(16),
//                                     child: CachedNetworkImage(
//                                       imageUrl: item.imageUrl,
//                                       fit: BoxFit.cover,
//                                       errorWidget: (context, url, error) =>
//                                           NoImageWidget.squared(),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 8,
//                               ),
//                               Text(
//                                 'The Afro night',
//                                 style: TextStyle(
//                                     fontSize: 18, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 'The House of music',
//                                 style: TextStyle(fontSize: 11),
//                               ),
//                               Text(
//                                 '2500 JPY',
//                                 style: TextStyle(fontSize: 11),
//                               ),
//                             ]))
//                     .toList()),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildEmptyView(BuildContext context) {
//     return SizedBox(
//       height: 200,
//       child: Center(
//         child: Text(
//           'Empty',
//         ),
//       ),
//     );
//   }
// }
