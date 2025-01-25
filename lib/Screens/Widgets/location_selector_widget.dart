import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Helper/Session.dart';
import '../../Helper/fetch_cities_cubit.dart';

class LocationSelectorWidget extends StatefulWidget {
  final List<Map> initialCities;
  const LocationSelectorWidget({Key? key, required this.initialCities})
      : super(key: key);
  @override
  State<LocationSelectorWidget> createState() => _LocationSelectorWidgetState();
}

class _LocationSelectorWidgetState extends State<LocationSelectorWidget> {
  final ScrollController _pageScrollController = ScrollController();
  final TextEditingController _cityName = TextEditingController();
  Timer? timer;
  late List<Map> selectedCities = widget.initialCities;
  @override
  void initState() {
    context.read<FetchCitiesCubit>().fetch();
    _pageScrollController.addListener(() {
      if (_pageScrollController.offset >=
          _pageScrollController.position.maxScrollExtent) {
        if (context.read<FetchCitiesCubit>().hasMoreData()) {
          context.read<FetchCitiesCubit>().fetchMore();
        }
      }
    });
    _cityName.addListener(() {
      if (timer?.isActive ?? false) timer?.cancel();
      timer = Timer(
        const Duration(milliseconds: 700),
        () {
          context.read<FetchCitiesCubit>().fetch(search: _cityName.text);
        },
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      expand: false,
      minChildSize: 0.6,
      maxChildSize: 0.91,
      builder: (context, ScrollController scrollController) {
        return BlocBuilder<FetchCitiesCubit, FetchCitiesState>(
          builder: (context, state) {
            return ListView(controller: _pageScrollController, children: [
              Padding(
                  padding: const EdgeInsets.only(
                      left: 20.0, right: 20, bottom: 40, top: 30,),
                  child: Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,),
                    child: Form(
                        child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Icon(Icons.close),
                              ),
                              const SizedBox(
                                width: 7,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.of(context).pop(selectedCities);
                                },
                                child: Container(
                                  padding: EdgeInsets.zero,
                                  decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      shape: BoxShape.circle,),
                                  child: const Padding(
                                    padding: EdgeInsets.all(5.0),
                                    child: Icon(Icons.done_rounded),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextFormField(
                          controller: _cityName,
                          decoration: InputDecoration(
                            isDense: false,
                            prefixIcon: const Icon(Icons.location_on),
                            hintText: getTranslated(context, 'CITY_NAME'),
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        InkWell(
                          onTap: () {
                            selectedCities.clear();
                            Navigator.pop(context, []);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3),),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Clear "),
                              ],
                            ),
                          ),
                        ),
                        BlocBuilder<FetchCitiesCubit, FetchCitiesState>(
                          builder: (context, state) {
                            if (state is FetchCitiesFail) {
                              return const Center(
                                child: Text("Something went wrong"),
                              );
                            }
                            if (state is FetchCitiesInInProgress) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (state is FetchCitiesSuccess) {
                              if (state.cities.isEmpty) {
                                return const Center(
                                  child: Text("No data"),
                                );
                              }
                              return Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListView.builder(
                                    itemCount: state.cities.length,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      final Map<String, dynamic> city =
                                          state.cities[index];
                                      final List selectedCityID = selectedCities
                                          .map((e) => e['id'])
                                          .toList();
                                      return GestureDetector(
                                        child: ListTile(
                                          onTap: () {
                                            if (selectedCityID
                                                .contains(city['id'])) {
                                              selectedCities.removeWhere(
                                                  (element) =>
                                                      element['id'] ==
                                                      city['id'],);
                                            } else {
                                              selectedCities.add(city);
                                            }
                                            setState(() {});
                                          },
                                          selected: selectedCityID
                                              .contains(city['id']),
                                          title: Text(city['name']),
                                        ),
                                      );
                                    },
                                  ),
                                  if (state.isLoadingMore)
                                    const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                  if (state.loadingMoreError)
                                    const Center(
                                      child: Text("Something went wrong"),
                                    ),
                                ],
                              );
                            }
                            return Container();
                          },
                        ),
                      ],
                    ),),
                  ),),
            ],);
          },
        );
      },
    );
  }
}
