$.ajax({
       url: "http://localhost:9090/api/ads/#(ad.id)/demands",
       type: "GET",
       contentType: "application/json; charset=utf-8"
       }).then(function (response) {
               var dataToReturn = [];
               for (var i=0; i < response.length; i++) {
               var tagToTransform = response[i];
               var newTag = {
               id: tagToTransform["demand"],
               text: tagToTransform["demand"]
               };
               dataToReturn.push(newTag);
               }
               $("#demands").select2({
                                       
                                       placeholder: "Select Demands for the Ad",
                                       
                                       tags: true,
                                       
                                       tokenSeparators: [','],
                                       
                                       data: dataToReturn
                                       });
               });
$.ajax({
       url: "http://localhost:9090/api/ads/#(ad.id)/offers",
       type: "GET",
       contentType: "application/json; charset=utf-8"
       }).then(function (response) {
               var dataToReturn = [];
               for (var i=0; i < response.length; i++) {
               var tagToTransform = response[i];
               var newTag = {
               id: tagToTransform["offer"],
               text: tagToTransform["offer"]
               };
               dataToReturn.push(newTag);
               }
               $("#offers").select2({
                                     
                                     placeholder: "Select Offers for the Ad",
                                     
                                     tags: true,
                                     
                                     tokenSeparators: [','],
                                     
                                     data: dataToReturn
                                     });
               });



$.ajax({
       url: "http://localhost:9090/api/cities",
       type: "GET",
       contentType: "application/json; charset=utf-8"
       }).then(function (response) {
               var dataToReturn = [];
               for (var i=0; i < response.length; i++) {
               var tagToTransform = response[i];
               var newTag = {
               id: tagToTransform["city"],
               text: tagToTransform["city"]
               };
               dataToReturn.push(newTag);
               }
               $("#city").select2({
                                    
                                    placeholder: "Select City for the Ad",
                                    
                                    tags: true,
                                    
                                    data: dataToReturn
                                    });
               });

$.ajax({
       url: "http://localhost:9090/api/departments/sorted",
       type: "GET",
       contentType: "application/json; charset=utf-8"
       }).then(function (response) {
               var dataToReturn = [];
               for (var i=0; i < response.length; i++) {
               var tagToTransform = response[i];
               var newTag = {
               id: tagToTransform["departmentName"],
               text: tagToTransform["departmentName"]
               
               
               };
               dataToReturn.push(newTag);
               }
               $("#adInfo.department").select2({
                                        
                                        placeholder: "Select Department for the Ad",
                                        
                                        tags: true,
                                        
                                        data: dataToReturn
                                        });
               });


$.ajax({
       url: "http://localhost:9090/api/departments/sorted",
       type: "GET",
       contentType: "application/json; charset=utf-8"
       }).then(function (response) {
               var dataToReturn = [];
               for (var i=0; i < response.length; i++) {
               var tagToTransform = response[i];
               var newTag = {
               id: tagToTransform["departmentName"],
               text: tagToTransform["departmentName"]
               
               
               };
               dataToReturn.push(newTag);
               }
               $("#departments").select2({
                                        
                                        placeholder: "Add Departments to the Perimeter",
                                        
                                        tags: true,
                                         
                                        tokenSeparators: [','],
                                         
                                        data: dataToReturn
                                        
                                    
                                        });
               });


