function populate_isni_ror(){
  var name = document.getElementById("thesis_or_dissertation_current_he_institution_group__current_he_institution_name");
  var isni = document.getElementById("thesis_or_dissertation_current_he_institution_group__current_he_institution_isni");
  var ror = document.getElementById("thesis_or_dissertation_current_he_institution_group__current_he_institution_ror");
  var index = name.options[name.selectedIndex].index;
  isni.selectedIndex = index;
  ror.selectedIndex = index;

}
