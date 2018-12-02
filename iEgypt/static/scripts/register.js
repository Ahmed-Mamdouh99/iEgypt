function add_viewer() {
    var viewer_arr = ["working_place_name", "working_place_type", "working_place_description"];
    var viewer_arr_names = ["Working place name", "Working place type", "Working place description"];
    var div = document.getElementById("varied_options");
    var y;
    for (y = 0; y < viewer_arr.length; y++) {
        var inner_div = document.createElement("div");
        inner_div.setAttribute('class', "form-group row");
        div.appendChild(inner_div);

        var label = document.createElement("label");
        label.setAttribute('class', "col-sm-2 col-form-label");
        label.innerHTML = viewer_arr_names[y];
        inner_div.appendChild(label);

        var super_inner_div = document.createElement("div");
        super_inner_div.setAttribute('class', "col-sm-4");
        inner_div.appendChild(super_inner_div);

        var input = document.createElement("input");
        input.setAttribute('name', viewer_arr[y]);
        input.setAttribute('class', "form-control");
        super_inner_div.appendChild(input);
    }
}

function add_contributor(){
  var contributor_arr = ["specialization", "portfolio_link", "years_of_experience"];
  var contributor_arr_names = ["Specialization", "Portfolio link", "Years of experience"];
  var div = document.getElementById("varied_options");
  var y;
  for (y = 0; y < contributor_arr.length; y++) {
      var inner_div = document.createElement("div");
      inner_div.setAttribute('class', "form-group row");
      div.appendChild(inner_div);

      var label = document.createElement("label");
      label.setAttribute('class', "col-sm-2 col-form-label");
      label.innerHTML = contributor_arr_names[y];
      inner_div.appendChild(label);

      var super_inner_div = document.createElement("div");
      super_inner_div.setAttribute('class', "col-sm-4");
      inner_div.appendChild(super_inner_div);

      var input = document.createElement("input");
      input.setAttribute('name', contributor_arr[y]);
      input.setAttribute('class', "form-control");
      super_inner_div.appendChild(input);
  }
}

function add_staff(){
  var staff_arr = ["hire_date", "working_hours", "payment_rate"];
  var staff_arr_names = ["Hire date", "Working hours", "Payment rate"];
  var div = document.getElementById("varied_options");
  var y;
  for (y = 0; y < staff_arr.length; y++) {
      var inner_div = document.createElement("div");
      inner_div.setAttribute('class', "form-group row");
      div.appendChild(inner_div);

      var label = document.createElement("label");
      label.setAttribute('class', "col-sm-2 col-form-label");
      label.innerHTML = staff_arr_names[y];
      inner_div.appendChild(label);

      var super_inner_div = document.createElement("div");
      super_inner_div.setAttribute('class', "col-sm-4");
      inner_div.appendChild(super_inner_div);

      var input = document.createElement("input");
      input.setAttribute('name', staff_arr[y]);
      input.setAttribute('class', "form-control");
      input.setAttribute('required', "")
      super_inner_div.appendChild(input);
  }
}

function show_selection(){
  var select = document.getElementsByName("user_type")[0];
  var sel = select.options[select.selectedIndex].text;
  var div = document.getElementById("varied_options");
  while(div.firstChild){
    div.removeChild(div.firstChild);
  }
  if (sel == "Viewer"){
    add_viewer();
  }else if(sel == "Contributor"){
    add_contributor()
  }else{
    add_staff()
  }
}

document.getElementsByName("user_type")[0].addEventListener("change", show_selection);
