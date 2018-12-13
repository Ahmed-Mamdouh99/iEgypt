function add_viewer() {
    var viewer_arr = ["working place", "working place type", "working place description"];
    var viewer_arr_types = ["text", "text", "text"];
    var div = document.getElementById("varied_options");
    var y;
    for (y = 0; y < viewer_arr.length; y++) {
        var inner_div = document.createElement("div");
        inner_div.setAttribute('class', "form-group row");
        div.appendChild(inner_div);

        var label = document.createElement("label");
        label.setAttribute('class', "col-sm-2 col-form-label");
        label.innerHTML = viewer_arr[y];
        inner_div.appendChild(label);

        var super_inner_div = document.createElement("div");
        super_inner_div.setAttribute('class', "col-sm-4");
        inner_div.appendChild(super_inner_div);

        var input = document.createElement("input");
        input.setAttribute('name', viewer_arr[y]);
        input.setAttribute('class', "form-control");
        input.setAttribute('type', viewer_Arr_types[y]);
        input.setAttribute('required', '');
        super_inner_div.appendChild(input);
    }
}

function add_contributor(){
  var contributor_arr = ["specialization", "portfolio link", "years of experience"];
  var contributor_arr_types = ["text", "link", "number"];
  var div = document.getElementById("varied_options");
  var y;
  for (y = 0; y < contributor_arr.length; y++) {
      var inner_div = document.createElement("div");
      inner_div.setAttribute('class', "form-group row");
      div.appendChild(inner_div);

      var label = document.createElement("label");
      label.setAttribute('class', "col-sm-2 col-form-label");
      label.innerHTML = contributor_arr[y];
      inner_div.appendChild(label);

      var super_inner_div = document.createElement("div");
      super_inner_div.setAttribute('class', "col-sm-4");
      inner_div.appendChild(super_inner_div);

      var input = document.createElement("input");
      input.setAttribute('name', contributor_arr[y]);
      input.setAttribute('class', "form-control");
      input.setAttribute('type', contributir_arr_types[y]);
      input.setAttribute('required', '');
      super_inner_div.appendChild(input);
  }
}

function add_staff(){
  var staff_arr = ["hire date", "working hours", "payment rate"];
  var staff_arr_types = ["date", "number", "float"];
  var div = document.getElementById("varied_options");
  var inner_div = document.createElement("div");
  inner_div.setAttribute('class', "form-group row");
  div.appendChild(inner_div);

  //Hire date
  var label = document.createElement("label");
  label.setAttribute('class', "col-sm-2 col-form-label");
  label.innerHTML = 'hire date';
  inner_div.appendChild(label);

  var super_inner_div = document.createElement("div");
  super_inner_div.setAttribute('class', "col-sm-4");
  inner_div.appendChild(super_inner_div);

  var input = document.createElement("input");
  input.setAttribute('name', 'hire date');
  input.setAttribute('class', "form-control");
  input.setAttribute('type', 'date');
  input.setAttribute('required', "")
  super_inner_div.appendChild(input);

  //Working hours
  inner_div = document.createElement("div");
  inner_div.setAttribute('class', "form-group row");
  div.appendChild(inner_div);

  label = document.createElement("label");
  label.setAttribute('class', "col-sm-2 col-form-label");
  label.innerHTML = 'working hours';
  inner_div.appendChild(label);

  super_inner_div = document.createElement("div");
  super_inner_div.setAttribute('class', "col-sm-4");
  inner_div.appendChild(super_inner_div);

  input = document.createElement("input");
  input.setAttribute('name', 'working hours');
  input.setAttribute('class', "form-control");
  input.setAttribute('type', 'number');
  input.setAttribute('required', "")
  super_inner_div.appendChild(input);

  //Payment rate
  var inner_div = document.createElement("div");
  inner_div.setAttribute('class', "form-group row");
  div.appendChild(inner_div);

  var label = document.createElement("label");
  label.setAttribute('class', "col-sm-2 col-form-label");
  label.innerHTML = 'payment rate';
  inner_div.appendChild(label);

  var super_inner_div = document.createElement("div");
  super_inner_div.setAttribute('class', "col-sm-4");
  inner_div.appendChild(super_inner_div);

  var input = document.createElement("input");
  input.setAttribute('name', 'payment rate');
  input.setAttribute('class', "form-control");
  input.setAttribute('type', 'number');
  input.setAttribute('step', 'any');
  input.setAttribute('min', '0');
  input.setAttribute('required', "")
  super_inner_div.appendChild(input);
}

function show_selection(){
  var select = document.getElementsByName("type")[0];
  if(select.length > 4){
    select.remove(0);
  }
  var sel = select.options[select.selectedIndex].text;
  var div = document.getElementById("varied_options");
  while(div.firstChild){
    div.removeChild(div.firstChild);
  }
  if (sel == "viewer"){
    add_viewer();
  }else if(sel == "contributor"){
    add_contributor()
  }else{
    add_staff()
  }
}

document.getElementsByName("type")[0].addEventListener("change", show_selection);
