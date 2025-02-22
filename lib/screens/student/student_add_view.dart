import 'package:al_furqan/application/auth/auth_cubit.dart';
import 'package:al_furqan/application/parent/parent_cubit.dart';
import 'package:al_furqan/application/services/asset_service.dart';
import 'package:al_furqan/application/services/parent_service.dart';
import 'package:al_furqan/application/services/student_service.dart';
import 'package:al_furqan/application/student/crud/student_cubit.dart';
import 'package:al_furqan/application/student/manage/student_manage_cubit.dart';
import 'package:al_furqan/models/student.dart';
import 'package:al_furqan/models/users.dart';
import 'package:al_furqan/screens/parent_add_view.dart';
import 'package:al_furqan/utils.dart';
import 'package:al_furqan/widgets/avatar_upload.dart';
import 'package:al_furqan/widgets/loading_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class StudentAddView extends StatefulWidget {
  final Student? student;
  final StudentManageCubit? studentManageCubit;
  const StudentAddView({super.key, this.student, this.studentManageCubit});

  @override
  State<StudentAddView> createState() => _StudentAddViewState();
}

class _StudentAddViewState extends State<StudentAddView> {
  final GlobalKey<FormState> _form = GlobalKey<FormState>();

  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  Users? _parent;
  XFile? _image;
  final _cubit = ParentCubit();

  bool _loading = false;

  late Student? _student;

  @override
  void initState() {
    super.initState();
    final admin =
        (context.read<AuthCubit>().state as UserAuthenticated).userData!;
    _cubit.watchParents(admin);
    if (widget.student != null) {
      _student = widget.student;
      _nameController.text = widget.student!.fullName;
      _ageController.text = widget.student!.age.toString();
      _phoneController.text = widget.student!.phone;
      ParentService.getParentByStudent(widget.student!.id).then((value) {
        setState(
          () {
            _parent = value;
            _student = widget.student!.copyWith(parent: value);
          },
        );
      });
    } else {
      _student = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text(_student == null
                ? context.loc.add_student
                : context.loc.update_student)),
        body: SafeArea(
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(250),
                                  bottomRight: Radius.circular(250),
                                ),
                                border: Border.symmetric(
                                    vertical: BorderSide(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        width: 24))),
                            child: AvatarUploadWidget(
                              cubit: widget.studentManageCubit,
                              onChange: (file) {
                                setState(() {
                                  _image = file;
                                });
                              },
                              loading: _loading,
                            )),
                      ),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              child: Form(
                                  key: _form,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _nameController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .loc.validation_enter_full_name;
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          icon: const Icon(Icons.person),
                                          labelText: context.loc.full_name,
                                        ),
                                      ),
                                      BlocBuilder<ParentCubit, ParentsState>(
                                        bloc: _cubit,
                                        builder: (context, state) {
                                          if (state is ParentsLoaded) {
                                            return DropdownSearch<Users>(
                                              validator: (value) {
                                                if (value == null) {
                                                  return context.loc
                                                      .validation_select_parent;
                                                }
                                                return null;
                                              },
                                              selectedItem: _parent,
                                              items: state.parents,
                                              itemAsString: (parent) =>
                                                  parent.fullName,
                                              clearButtonProps:
                                                  const ClearButtonProps(
                                                isVisible: true,
                                              ),
                                              dropdownDecoratorProps:
                                                  DropDownDecoratorProps(
                                                dropdownSearchDecoration:
                                                    InputDecoration(
                                                  labelText: context.loc.parent,
                                                  hintText: context.loc
                                                      .form_select_search_parent,
                                                ),
                                              ),
                                              dropdownBuilder:
                                                  (context, selectedItem) {
                                                return Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.person_3),
                                                    if (selectedItem != null)
                                                      Expanded(
                                                        child: ListTile(
                                                          leading: selectedItem
                                                                          .image !=
                                                                      null &&
                                                                  selectedItem
                                                                      .image!
                                                                      .isNotEmpty
                                                              ? CircleAvatar(
                                                                  foregroundImage:
                                                                      CachedNetworkImageProvider(
                                                                          AssetService.composeImageURL(
                                                                              selectedItem)),
                                                                )
                                                              : CircleAvatar(
                                                                  child: Text(selectedItem
                                                                      .fullName
                                                                      .characters
                                                                      .first
                                                                      .toUpperCase()),
                                                                ),
                                                          title: Text(
                                                              selectedItem
                                                                  .fullName),
                                                        ),
                                                      )
                                                    else
                                                      Text(context.loc
                                                          .form_select_parent),
                                                  ],
                                                );
                                              },
                                              onChanged: (value) {
                                                setState(() {
                                                  _parent = value;
                                                });
                                              },
                                              popupProps: PopupProps.menu(
                                                itemBuilder: (context, item,
                                                        isSelected) =>
                                                    ListTile(
                                                  leading: item.image != null &&
                                                          item.image!.isNotEmpty
                                                      ? CircleAvatar(
                                                          foregroundImage:
                                                              CachedNetworkImageProvider(
                                                                  AssetService
                                                                      .composeImageURL(
                                                                          item)),
                                                        )
                                                      : CircleAvatar(
                                                          child: Text(item
                                                              .fullName
                                                              .characters
                                                              .first
                                                              .toUpperCase()),
                                                        ),
                                                  title: Text(item.fullName),
                                                ),

                                                showSearchBox:
                                                    true, // Enables autocomplete
                                                searchFieldProps:
                                                    TextFieldProps(
                                                  decoration: InputDecoration(
                                                      prefixIcon: const Icon(
                                                          Icons.person_3),
                                                      hintText: context.loc
                                                          .form_select_search_parent),
                                                ),
                                              ),
                                            );
                                          } else if (state is ParentsEmpty) {
                                            return IconButton(
                                                onPressed: () {
                                                  Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              const ParentAddView()));
                                                },
                                                icon: const Icon(
                                                    Icons.person_add));
                                          } else {
                                            return const Center(
                                                child:
                                                    CircularProgressIndicator());
                                          }
                                        },
                                      ),
                                      TextFormField(
                                        controller: _ageController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return context
                                                .loc.validation_enter_age;
                                          }
                                          return null;
                                        },
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        decoration: InputDecoration(
                                          icon: const Icon(Icons.date_range),
                                          labelText: context.loc.age,
                                        ),
                                      ),
                                      TextFormField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 10,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly
                                        ],
                                        decoration: InputDecoration(
                                          icon: const Icon(Icons.phone),
                                          labelText: context.loc.phone,
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                            if (_student == null)
                              ElevatedButton(
                                  onPressed: () {
                                    if (_form.currentState!.validate()) {
                                      try {
                                        setState(() {
                                          _loading = true;
                                        });
                                        context
                                            .read<StudentCubit>()
                                            .addStudent(
                                                name: _nameController.text,
                                                age: int.parse(
                                                    _ageController.text),
                                                parent: _parent!,
                                                teacher: (context
                                                            .read<AuthCubit>()
                                                            .state
                                                        as UserAuthenticated)
                                                    .userData!,
                                                image: _image,
                                                phone: _phoneController.text)
                                            .then((_) {
                                          setState(() {
                                            _loading = false;
                                          });
                                          Navigator.of(context).pop();
                                        });
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content:
                                              Text(context.loc.unknown_error),
                                        ));
                                      }
                                    }
                                  },
                                  child: Text(_student == null
                                      ? context.loc.add_student
                                      : context.loc.update_student))
                            else if (_student != null)
                              ElevatedButton(
                                  onPressed: () {
                                    if (_form.currentState!.validate()) {
                                      try {
                                        StudentService.updateStudent(
                                                image: _image,
                                                student: _student!,
                                                fullName: _nameController.text,
                                                age: int.parse(
                                                    _ageController.text),
                                                parent: _parent!,
                                                teacher: (context
                                                            .read<AuthCubit>()
                                                            .state
                                                        as UserAuthenticated)
                                                    .userData!,
                                                phone: _phoneController.text)
                                            .then((_) {
                                          Navigator.of(context).pop();
                                        });
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text(e.toString()),
                                        ));
                                      }
                                    }
                                  },
                                  child: Text(context.loc.update_student)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (_loading) LoadingWidget()
                ],
              ),
            ),
          ),
        ));
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }
}
