
<workloads>
    <div id="main" class="row form-group col-xs-12">
        <table class="table table-sm col-xs-12">
            <thead>
              <tr>
                <th scope="col">Workload</th>
                <th scope="col">Image</th>
                <th scope="col">Current</th>
                <th scope="col"></th>
                <th scope="col">Available</th>
                <th scope="col">Created at</th>
              </tr>
            </thead>
            {{range $w := .workloads}}
                {{if lt 0 (len $w.Containers)}}
                  {{range $c := $w.Containers}}
                  <tbody>
                    <tr>
                        <th scope="row">{{$w.ID}}</th>
                        <td>{{$c.Name}}</td>
                        <div class="app">
                        <td class="cut-text" td_id="{{ $c.Current.ID }}">{{ $c.Current.ID}}</td>
                    {{range $i, $a := $c.Available}}{{if lt $i 3}}
                            {{if eq $c.Current.ID $a.ID}}
                                <td><img id="current_{{$c.Name}}" src="/static/img/equal.png" width="30" height="30"/></td>
                                <td class="cut-text" title="{{ $a.ID }}" container="{{ $a.ID }}" data-container="body" data-placement="top">{{ $a.ID }}</td>
                            {{else}}
                                {{ if eq $.read_only "true" }}
                                    <td><img  id="icon_{{$c.Name}}_{{$i}}" data-toggle="modal" data-target="#{{$c.Name}}_{{$i}}" src="/static/img/not-equal.png" width="30" height="30"/></td>
                                    <td class="cut-text" title="{{ $a.ID }}" container="{{ $a.ID }}" data-container="body" data-placement="top">{{ $a.ID }}</td>
                                {{ else }}
                                <td><img  id="icon_{{$c.Name}}_{{$i}}" data-toggle="modal" data-target="#{{$c.Name}}_{{$i}}" src="/static/img/not-equal.png" width="30" height="30" style="cursor: pointer;"/></td>
                                    <td class="cut-text" title="{{ $a.ID }}" container="{{ $a.ID }}" data-container="body" data-placement="top">{{ $a.ID }}</td>
                                    <!-- Modal -->
                                    <div class="modal fade" id="{{$c.Name}}_{{$i}}" role="dialog">
                                      <div class="modal-dialog modal-sm">
                                        <div class="modal-content">
                                          <div class="modal-header">
                                            <button type="button" class="close" data-dismiss="modal">&times;</button>
                                            <h4 class="modal-title">Promote {{$c.Name}}</h4>
                                          </div>
                                          <div class="modal-body">
                                            <p>{{$c.Current.ID}} --> {{$a.ID}}</p>
                                          </div>
                                          <div class="modal-footer {{$c.Name}}_{{$i}}">
                                            <button id="approve_{{$c.Name}}_{{$i}}" container-name="{{$c.Name}}" workload-id="{{$w.ID}}" current-id="{{$c.Current.ID}}" available-id="{{$a.ID}}" type="button" class="btn btn-default" data-dismiss="modal">Approve</button>
                                            <button type="button" class="btn btn-default" data-dismiss="modal">Cancel</button>
                                          </div>
                                        </div>
                                      </div>
                                    </div>
                                {{end}}
                            {{end}}
                            <td>{{ $a.CreatedAt }}</td>
                            </div>
                      </tr>
                  </tbody>
                  <script>
                      var data =$('[td_id="{{ $c.Current.ID }}"]').text();
                      var arr = data.split(':');
                      $('[td_id="{{ $c.Current.ID }}"]').text(arr.pop());
                      data =$('[container="{{ $a.ID }}"]').text();
                      arr = data.split(':');
                      $('[container="{{ $a.ID }}"]').text(arr.pop());
                      
                      $( "#approve_{{$c.Name}}_{{$i}}" ).click(function($http) {
                          var aid = $(this).attr( "available-id" );
                          var cid = $(this).attr( "current-id" );
                          var wid = $(this).attr( "workload-id" );
                          var cn = $(this).attr( "container-name" );
                      
                          var spec = '{ "'+wid+'":[ { "Container": "'+cn+'", "Current": "'+cid+'", "Target": "'+aid+'" } ] }';
                          var release = JSON.stringify(
                              {
                                "Cause": {
                                  "Message": "",
                                  "User": "Flux-web"
                                },
                                "Spec": {
                                  "ContainerSpecs": $.parseJSON(spec),
                                  "Kind": "execute",
                                  "SkipMismatches": true
                                },
                                "Type": "containers"
                          });
                          console.log(release);
                          $("#icon_{{$c.Name}}_{{$i}}").attr("src","/static/img/spinner.gif");
                          $.ajax({
                              url: '/release',
                              type: 'POST',
                              contentType: "application/json;",
                              data: release,
                              success: function () {
                                $("#icon_{{$c.Name}}_{{$i}}").attr("src","/static/img/equal.png");
                                $("#current_{{$c.Name}}").attr("src","/static/img/not-equal.png");
                              },
                              fail: function () {
                                $("#icon_{{$c.Name}}_{{$i}}").attr("src","/static/img/not-equal.png");
                                alert("Error in upgrade to " + aid);
                              }, 
                              error: function () {
                                $("#icon_{{$c.Name}}_{{$i}}").attr("src","/static/img/not-equal.png");
                                alert("Error in upgrade to " + aid);
                              }  
                          });
                      });
                  </script>
                  <tbody>
                      <tr>
                          <th scope="row" style="border-top:white"></th>
                          <td style="border-top:white"></td>
                          <div class="app" style="border-top:white">
                          <td class="cut-text" style="border-top:white"></td>
                    {{end}}{{end}}
                    {{end}}
                {{end}}
            {{end}}
        </table>
    </div>
</workloads>