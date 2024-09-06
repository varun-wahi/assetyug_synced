import { Component, ElementRef, inject, ViewChild, ViewEncapsulation } from '@angular/core';
import { AssetsService } from './assets.service';
import { AuthService } from 'src/app/shared/auth.service';
import * as XLSX from 'xlsx'; 
import { Assets } from './assets';
import { ExtraFieldName } from './extraFieldName';
import { FormArray, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { ShowFieldsData } from './showFieldsData';
import { MandatoryFields } from './mandatoryFields';
import { CompanyCustomer } from './company-cutomer';
import { RoleAndPermission } from './RoleAndPermission';
import { PageEvent } from '@angular/material/paginator';
import { PaginationResult } from './paginationResult';
import {MatSnackBar} from '@angular/material/snack-bar';


@Component({
  selector: 'app-assets',
  templateUrl: './assets.component.html',
  styleUrls: ['./assets.component.css'],
  encapsulation: ViewEncapsulation.None 
})
export class AssetsComponent {
  private _snackBar = inject(MatSnackBar);
  @ViewChild('closeBox2') closeBox2: ElementRef | undefined ;
  loading:boolean=true;
  tempId:any;
  paginationResult!:PaginationResult;
  assets!:any[];
  searchedAssets!:any[];
  email:any;
  excelFile:any;
  fileName= 'AssetSheet.xlsx'; 
  sortoption:string='';
  searchText:string='';
  imgId:string='';
  assetName:string='';
  detailedAsset:boolean=false;
  previewAsset:boolean=false;
  mainAsset:boolean=true;
  currDetails!:Assets;
  hoverOverSidebar=true;
  extraFieldName!:ExtraFieldName[];
  extraFieldNameList!:string[];
  selectedExtraColums :string[]=[];
  selectedExtraColumsNameValue:any[]=[];
  fieldNameValueMap!:object;
  selectedCompanyCustomer!:string;
 
  selectedItems = [];
  

  showFieldsList!:ShowFieldsData[];
  mandatoryFieldsList!:MandatoryFields[];
  mandatoryFieldsMap!:Map<string,boolean>;
  showFieldsMap!:Map<string,boolean>;
  extraFieldNameMap!:Map<String,ExtraFieldName>;
  
  dropdownSettings: any ;
  assetForm!:FormGroup;
  filterForm!:FormGroup;
  myImage:any;
  showAlert: boolean = false; // Flag to toggle alert visibility
  alertMessage: string = ''; // Alert message
  alertType: string = 'success'; // Alert type: success, warning, error, etc.

  editVisibility:boolean=false;
  editButtonId:number=-1;
  assetList!:Assets[];
  companyId!:any;
  userRole: any;

  assetListWithExtraFields:any = [];
  searchData!:any;
  searchDataBy!:string;
  sortedBy!:string;

  loadingScreen=false;
  
  companyCustomerList!:CompanyCustomer[];
  companyCustomerArr!:string[];

  customerIdNameMap!:Map<String,String>;

  userRoleDetails!:RoleAndPermission;

  filterShow:boolean=false;

  panelOpenState = false;

  extraFieldFilterList!:Map<String,String>;
  extraFieldFilterListValue!:Map<String,String>;
  filterList:any=[];
  selectedFilterList:any=[];
  selectFilter!:string;
  savedExtraColumn!:any
  pageSize:number=5;
  totalLength:number=0;
  pageEvent!: PageEvent;
  pageIndex:number=0;
  assetListWithExtraFieldsWithoutFilter=[]
  myList:string[]=[];
  mandatoryFieldFilterList!:Map<string,Boolean>;

  appliedFilterList!:Set<string>;
  appliedFilterListMap!:Map<string,string>;
  selectedExtraColumsMap!:Map<string,Boolean>;
  showMandatoryBasicFields!:Map<string,Boolean>;
  checkBoxColor="primary"
  myArray=[]

  constructor(private assetService:AssetsService,private authService:AuthService,private formBuilder:FormBuilder){
   
   }
  ngOnInit(){
    if(localStorage.getItem("assetIdDetail")!=null){
      this.tempId=localStorage.getItem("assetIdDetail")
      this.assetService.getAssetDetails( this.tempId).subscribe((data:Assets)=>{
        
        this.changeAssetDetails(data)
        console.log(data)
      })
      localStorage.removeItem("assetIdDetail")
     
    }
    // this.assetService.componentMethodCalled$.subscribe((data:any) => {
    //   console.log("--------------------called "+ data)
    //   this.mainAsset=true;
    //   this.detailedAsset=true;
    //   this.currDetails=data;
    // });
    this.loading=true;
    this.selectedExtraColumsMap=new Map<string,Boolean>;
    console.log("Loading->"+this.loading)

    
    console.log("extra selected columns--->"+localStorage.getItem("selectedExtraColumsAssets")+" "+localStorage.getItem("showMandatoryBasicFieldsAssets"))
    this.savedExtraColumn=localStorage.getItem("selectedExtraColumsAssets")
    if(this.savedExtraColumn!=null){
      this.selectedExtraColums=JSON.parse(this.savedExtraColumn);
      this.selectedExtraColums.forEach((data)=>{
        this.selectedExtraColumsMap.set(data,true);
      })
    }
    this.selectedExtraColumsMap.forEach((ele,val)=>{
      console.log(ele+"----"+val)
    })
    
    this.sortedBy="";
    this.searchData=null;
    this.filterList=[];
    this.appliedFilterList=new Set<string>();
    this.showMandatoryBasicFields=new Map<string,Boolean>();
    this.appliedFilterListMap=new Map<string,string>;
    // this.selectFilter="";
    this.mandatoryFieldFilterList=new Map<string,Boolean>();
    this.savedExtraColumn=localStorage.getItem("showMandatoryBasicFieldsAssets")
    this.myArray=JSON.parse(this.savedExtraColumn)
    console.log("MYARRAY"+this.myArray)

    this.myList=['image','assetId','name','serialNumber','category','customer','location','status'];
    this.showMandatoryBasicFields.set('image',true);
    this.showMandatoryBasicFields.set('assetId',true);
    this.showMandatoryBasicFields.set('name',true);
    this.myList.forEach((x)=>{
      if(this.myArray!=null){
        this.myArray.forEach((ele:any)=>{
          if(x===ele){
            this.showMandatoryBasicFields.set(x,true);
          }
        })
     }
     else{
      this.showMandatoryBasicFields.set(x,true);
     }
      // if()
      
      this.mandatoryFieldFilterList.set(x,true);
    });

   
    console.log(this.showMandatoryBasicFields)
    this.panelOpenState = false;
    this.customerIdNameMap=new Map<String,String>();
    this.extraFieldFilterList=new Map<String,String>();
    this.filterShow=false;
    this.userRole=localStorage.getItem('role');
    this.email=localStorage.getItem('user');
    this.companyId=localStorage.getItem('companyId');
    this.mandatoryFieldsMap = new Map<string, boolean>();
    this.showFieldsMap = new Map<string, boolean>();
    console.log(this.email);
    

    this.assetForm=this.formBuilder.group({
      name:[''],
      customer:[''],
      customerId:[''],
      serialNumber:[''],
      category:[''],
      location:[''],
      status:[''],
      image:[''],
      email:[this.email],
      companyId:[this.companyId]
     

    });
    
    this.filterForm=this.formBuilder.group({
      assetId:['',Validators.required],
      name:['',Validators.required],
      customer:['',Validators.required],
      serialNumber:['',Validators.required],
      category:['',Validators.required],
      location:['',Validators.required],
      status:['',Validators.required],
      email:[this.email],
      companyId:[this.companyId]
      // extraFields: this.formBuilder.array([])
     

    });
    this.assetService.getRoleAndPermission(this.companyId,this.userRole).subscribe((data)=>{
      this.userRoleDetails=data;
      console.log(this.userRoleDetails);
    },
    err=>{
      console.log(err);
    });
    this.assetService.getCompanyCustomerList(this.companyId).subscribe((data)=>{
      this.companyCustomerList=data;
      this.companyCustomerList.forEach((x)=>{
        this.customerIdNameMap.set(x.id,x.name);
      })
      console.log("companyCustomer"+this.companyCustomerList)
    },
    (err)=>{
      console.log(err);
    })

    this.advanceFilterFunc();
    this.assetService.getAllMandatoryFields(this.companyId).subscribe((data)=>{
      this.mandatoryFieldsList=data;
      // console.log("mandatory----------------------->",this.mandatoryFieldsList)
      if(this.mandatoryFieldsList.length>0){
      this.mandatoryFieldsList?.forEach((x)=>{
        this.mandatoryFieldsMap.set(x.name,x.mandatory);
      })
    }
    },
    (err)=>{
      console.log(err);
    })
    this.assetService.getAllShowFields(this.companyId).subscribe((data)=>{
      this.showFieldsList=data;
      console.log("show----------------------->",this.showFieldsList)
      this.selectedFilterList=[]
      if(this.showFieldsList.length>0){
      this.showFieldsList?.forEach((x)=>{
        this.filterList.push(x.name);
        this.selectedFilterList.push(x.name);
        this.filterForm.addControl(x.name,this.formBuilder.control('',Validators.required));
        this.showFieldsMap.set(x.name,x.show);
        if(x.show==true){
          this.extraFieldFilterList.set(x.name,x.type);
        }
      })
    }
      
      if(this.showFieldsList!=null){
        if(this.showFieldsList.length>0){
      this.showFieldsList.forEach((x)=>{
        if(x.show==true)
        this.assetForm.addControl(x.name,this.formBuilder.control(''));
      })
    }
    }
    
    },
    (err)=>{
      console.log(err);
    },
    ()=>{
      this.assetService.getExtraFieldName(this.companyId).subscribe((data)=>{
      
     
        this.extraFieldName=data;
        let arr:string[]=[];
      this.extraFieldName.forEach((x)=>{
      
        console.log(x.name+" "+this.showFieldsMap.get(x.name))
        this.extraFieldNameMap?.set(x.name,x);
          if(this.showFieldsMap.get(x.name)==true){
          arr.push(x.name);
          }
        })
     
        this.extraFieldNameList=arr;
        console.log(this.extraFieldNameList)
        
     
       
        
        
      },
      (err)=>{
        console.log(err);
      })
    })

    





   
    this.selectedItems = [

    ];

    this.dropdownSettings= {
      singleSelection: false,
      idField: 'item_id',
      textField: 'item_text',
      selectAllText: 'Select All',
      unSelectAllText: 'UnSelect All',
      itemsShowLimit: 2,
      allowSearchFilter: true
    };

    
    

    
    // this.loading=false;
    // console.log("Loading->"+this.loading)
  }
  get appliedFilterListSize(): number {
    return this.appliedFilterList.size;
  }

  advanceFilterFunc(){
    this.loading=true;
    this.assetService.advanceFilter(this.filterForm.value,this.pageIndex,this.pageSize,this.sortedBy,this.searchData).subscribe((data)=>{
      console.log("this.searchData"+ this.searchData)
      console.log("Loading->"+this.loading)
      console.log(data);
      this.assetListWithExtraFields=[];
      this.paginationResult=data;
      this.totalLength=this.paginationResult.totalRecords;
    this.assets=this.paginationResult.data;
    const jsonList:string[]=this.paginationResult.data;
    jsonList.forEach((workorder)=>{
      const jsonObject:any = JSON.parse(workorder);
      console.log(typeof(jsonObject))
      this.assetListWithExtraFields.push(jsonObject)
    });
    this.assetListWithExtraFieldsWithoutFilter=this.assetListWithExtraFields;
    console.log(this.assetListWithExtraFields);
    // this.loading=false;
    // console.log("Loading->"+this.loading)
    },
  (err)=>{
    console.log(err);
    this.loading=false;
  },
()=>{
  this.searchedAssets=this.assets;
  // console.log("Loading->"+this.loading)
  this.loading=false;
  console.log("Loading->"+this.loading)
})
  }

  handlePageEvent(e: PageEvent) {
    this.pageEvent = e;
    this.totalLength = e.length;
    this.pageSize = e.pageSize;
    this.pageIndex = e.pageIndex;
    console.log(this.pageIndex);

    this.advanceFilterFunc();
   
    
  }

  onChange(value: string): void {
    if (this.selectedExtraColums.includes(value)) {
      this.selectedExtraColums = this.selectedExtraColums.filter((item) => item !== value);
    } else {
      this.selectedExtraColums.push(value);
    }
    console.log(this.selectedExtraColums)
    this.selectedExtraColums.sort();

  }
 
  onSubmit(event:any){
  const file = event.target.files[0];
  const formData = new FormData();
  formData.append('file', file);
  

    this.assetService.addAssets(formData,this.companyId).subscribe((data)=>{
      console.log("Successfully uploaded");
    },
    (err)=>{
      console.log(err);
    })
  }
  onAdd(){
    alert("Successfully Uploaded File");
    this.ngOnInit();
  }
  exportexcel(): void 
    {
       /* table id is passed over here */   
       let element = document.getElementById('asset-table'); 
       const ws: XLSX.WorkSheet =XLSX.utils.table_to_sheet(element);

       /* generate workbook and add the worksheet */
       const wb: XLSX.WorkBook = XLSX.utils.book_new();
       XLSX.utils.book_append_sheet(wb, ws, 'Sheet1');

       /* save to file */
       XLSX.writeFile(wb, this.fileName);
			
    }

    removeFilter(){
      this.searchedAssets=this.assets;
      this.sortoption='';
      this.ngOnInit();
    }

    imageUpload(event:any){
 
      const file = event.target.files[0];
    const reader = new FileReader();
    reader.readAsDataURL(file);
    reader.onload = () => {
  
    
   
      this.myImage=reader.result;
      
   
        };
    
   


    }
//added new
    editButtonVisibile(id:number){
  //  console.log(id);
      this.editButtonId=id;
      this.editVisibility=true;
   
    }
    editButtonNotVisible(){
      
      this.editVisibility=false;
      this.editButtonId=-1;
    }

    addAsset(event: Event){
      event.preventDefault();
      let myAsset:Assets;
      let extraFieldValueMap=new Map<String,string>();
      let extraFieldTypeMap=new Map<String,string>();
      this.showFieldsList?.forEach((x)=>{
        if(x.show==true){
        extraFieldValueMap.set(x.name,this.assetForm.get(x.name)?.value);
        extraFieldTypeMap.set(x.name,this.assetForm.get(x.type)?.value);
        }
      })
      this.assetForm.controls['image'].setValue(this.myImage);
      console.log(this.assetForm.value);
      let valid=1;
      console.log(this.mandatoryFieldsList)
      this.mandatoryFieldsList?.forEach((val)=>{
        console.log("-============>",val.mandatory+" "+this.assetForm.get(val.name)?.value);
        if(this.showFieldsMap.get(val.name)==false){
          valid=1;
        }
        else if((val.mandatory==true)&&( this.assetForm.get(val.name)?.value==null||this.assetForm.get(val.name)?.value=='')){
  
          // console.log("Fill Mandatory Field '"+this.toCamelCase(val.name)+"'")
          this.triggerAlert("Fill Mandatory Field '"+this.toCamelCase(val.name)+"'","warning");
          // alert("Fill Mandatory Field '"+this.toCamelCase(val.name)+"'")
          // this.openSnackBar("Fill Mandatory Field '"+this.toCamelCase(val.name)+"'","Close")
          valid=0;
         
        }
        else if((val.mandatory==true)&&(this.showFieldsMap.get(val.name)==true) &&( this.assetForm.get(val.name)?.value==null||this.assetForm.get(val.name)?.value=='')){
       
          // console.log("Fill Mandatory Field '"+this.toCamelCase(val.name)+"'")
          this.triggerAlert("Fill Mandatory Field '"+this.toCamelCase(val.name)+"'","warning");
          // alert("Fill Mandatory Field '"+this.toCamelCase(val.name)+"'")
          // this.openSnackBar("Fill Mandatory Field '"+this.toCamelCase(val.name)+"'","Close")
          valid=0;
         
        }
        
        
      })
      if(valid==0){
        return;
      }
      this.selectedCompanyCustomer=this.assetForm.controls['customer'].value;
      if(this.selectedCompanyCustomer!=null){
        this.companyCustomerArr=this.selectedCompanyCustomer.split(',');
        this.assetForm.controls['customer'].setValue(this.companyCustomerArr[0]);
        this.assetForm.controls['customerId'].setValue(this.companyCustomerArr[1]);
        }

        console.log("assetFormData - "+this.assetForm.value)
      this.assetService.addNewAsset(this.assetForm.value).subscribe((data)=>{
        
        myAsset=data;
        console.log("Asset Uploaded"+data);
      },
      (err)=>{
        console.log(err);
      },
      ()=>{
        if (this.closeBox2) {
          this.closeBox2.nativeElement.click();
        }
        this.ngOnInit();
        this.showFieldsList?.forEach((x)=>{
          const obj={
              "email":this.email,
              "companyId":this.companyId,
              "name":x.name,
              "value":extraFieldValueMap.get(x.name),
              "assetId":myAsset.id,
              "type":extraFieldTypeMap.get(x.name)
          }
          console.log("extra fields obj"+obj.companyId+" "+obj.name+" "+obj.value+" assetId "+obj.assetId)
          this.assetService.addExtraFields(obj).subscribe((data)=>{
            console.log("added extra fields");
          },
          (err)=>{
            console.log(err);
          })
        })
      })
    }

    changeAssetDetails(item:Assets){
      this.mainAsset=!this.mainAsset;
      this.detailedAsset=!this.detailedAsset;
      this.currDetails=item;

    }
    changeAssetPreview(item:Assets){
      this.mainAsset=!this.mainAsset;
      this.previewAsset=!this.previewAsset;
      this.currDetails=item;

    }
    onBackClicked(eventData:{show:boolean}){
      this.detailedAsset=false;
      this.mainAsset=true;
      console.log(this.previewAsset);
    }
    onBackClicked2(eventData:{show:boolean}){
      this.previewAsset=false;
      this.mainAsset=true;
    }
    toCamelCase(str: string): string {
      return str.replace(/\b\w/g, (char) => char.toUpperCase());
    }
    triggerAlert(message: string, type: string) {
      console.log("triiger")
      this.alertMessage = message;
      this.alertType = type;
      this.showAlert = true;
      // You can set a timeout to automatically hide the alert after a certain time
      setTimeout(() => {
        this.showAlert = false;
      }, 50000); // Hide the alert after 5 seconds (adjust as needed)
    }
    Echo(){
      console.log("ecgo")
    }
    getAllAssetData(){
      this.assetService.getAssetsAllDetails(this.companyId).subscribe((data)=>{
        this.assetListWithExtraFields=[]
        this.assets=data;
        const jsonList:string[]=data;
        jsonList.forEach((workorder)=>{
          const jsonObject:any = JSON.parse(workorder);
          console.log(typeof(jsonObject))
          this.assetListWithExtraFields.push(jsonObject)
        })
        console.log(this.assetListWithExtraFields)
      },
      (err)=>{
        console.log(err);
      },
      ()=>{
  
      })
    }

    onSearch(){
      this.loading=true;
      console.log(this.searchData);
      let mySearch=this.searchData;
      mySearch=mySearch?.trim();
   
      if(mySearch==""){
        this.searchData=null;
      }
      // this.searchData = data.toLowerCase();
      // this.filterAssets();
      this.advanceFilterFunc();
    }

    // filterAssets() {
    //   this.assetListWithExtraFields=this.assetListWithExtraFieldsWithoutFilter;
   
    //   if (this.searchData==''||this.searchData==null) {

    // this.assetListWithExtraFields=this.assetListWithExtraFieldsWithoutFilter;
    //     return;
    //   }
    //   this.assetListWithExtraFields=this.assetListWithExtraFields.filter((mydata: any)=>{
    //     //  console.log(mydata)
    //         let filterData:any;
    //         if(mydata.name.toLowerCase().includes(this.searchData.toLowerCase())||mydata.assetId==this.searchData||mydata.serialNumber.toLowerCase().includes(this.searchData.toLowerCase())||mydata.category.toLowerCase().includes(this.searchData.toLowerCase())||mydata.customer.toLowerCase().includes(this.searchData.toLowerCase())||mydata.location.toLowerCase().includes(this.searchData.toLowerCase())||mydata.status.toLowerCase().includes(this.searchData.toLowerCase())){
    //           filterData=mydata;
    //         }
    //         else{
    //           let flag=0;
    //           this.selectedExtraColums.forEach((x)=>{
               
    //            if(isNaN(mydata[x])&&mydata[x].toLowerCase().includes(this.searchData.toLowerCase())){
    //               filterData=mydata;
    //               flag=1;
    //             }
    //             else if((mydata[x]==this.searchData)){
    //               filterData=mydata;
    //               flag=1;
    //             }
                
    //           })
    //           if(flag==0){
    //           filterData=false;
    //           }
    //         }
    //         return filterData;
           
    //         // keys.forEach((key)=>{
    //         //   const myString:String =data[key];
    //         //   if(myString!=null&&myString.toLowerCase().includes(value.toLowerCase())){
    //         //     filterData=data;
    //         //   }
             
              
              
    //         // })
    //         // return filterData;
    //       });
     
    // }
    // searchClick(){
    //   this.loadingScreen=true;
    //   if(this.searchData?.trim()==null||this.searchData?.trim()==''||this.searchDataBy==''){
  
    //     this.getAllAssetData();
        
    //     return;
    //   }
    //   if(this.searchDataBy==''||this.searchDataBy==null){
    //     alert("Please select the category from drop down");
    //     return;
    //   }
    //   // this.loadingScreen=true;
      
    //     this.assetService.getSearchedAssetList(this.companyId,this.searchData?.trim(),this.searchDataBy).subscribe((data)=>{
    //       this.assetListWithExtraFields=[];
        
    //     this.assetList=data;
    //     const jsonList:string[]=data;
    //     jsonList.forEach((workorder)=>{
    //       const jsonObject:any = JSON.parse(workorder);
          
    //       this.assetListWithExtraFields.push(jsonObject)
    //     })
      
          
    //     },
    //     (err)=>{
    //       console.log(err);
    //     },()=>{
    //       this.loadingScreen=false;
    //     })
      
      
    // }
    // searchBy(data:string){
    //   this.searchDataBy=data;
    //   console.log(data)
    //   this.sortedBy='';
    // }
    // removeSearchDataBy(){
    //   this.searchDataBy='';
    //   this.getAllAssetData();
    // }
    sortBy(data:string){
      this.searchDataBy='';
      this.sortedBy=data;
      console.log("Sorted By:"+data)
      console.log(this.extraFieldName);
      console.log(this.selectedExtraColumsNameValue);
      const type=this.extraFieldNameMap?.get(data)?.type;
    //   this.assetService.advanceFilter(this.filterForm.value,this.pageIndex,this.pageSize,this.sortedBy).subscribe((data)=>{
    //     console.log(data);
    //     this.assetListWithExtraFields=[]
    //   this.paginationResult=data;
    //   this.totalLength=this.paginationResult.totalRecords;
    //   this.assets=this.paginationResult.data;
    //   const jsonList:string[]=this.paginationResult.data;
    //   jsonList.forEach((workorder)=>{
    //     const jsonObject:any = JSON.parse(workorder);
    //     console.log(typeof(jsonObject))
    //     this.assetListWithExtraFields.push(jsonObject)
    //   });
    //   this.assetListWithExtraFieldsWithoutFilter=this.assetListWithExtraFields;
    //   console.log(this.assetListWithExtraFields);
    //   this.loading=false;
    //   },
    // (err)=>{
    //   console.log(err);
    //   this.loading=false;
    // })
    this.advanceFilterFunc();
    }
    removeSort(){
     this.sortedBy='';
  //    this.assetService.advanceFilter(this.filterForm.value,this.pageIndex,this.pageSize,this.sortedBy).subscribe((data)=>{
  //     console.log(data);
  //     this.assetListWithExtraFields=[]
  //   this.paginationResult=data;
  //   this.totalLength=this.paginationResult.totalRecords;
  //   this.assets=this.paginationResult.data;
  //   const jsonList:string[]=this.paginationResult.data;
  //   jsonList.forEach((workorder)=>{
  //     const jsonObject:any = JSON.parse(workorder);
  //     console.log(typeof(jsonObject))
  //     this.assetListWithExtraFields.push(jsonObject)
  //   });
  //   this.assetListWithExtraFieldsWithoutFilter=this.assetListWithExtraFields;
  //   console.log(this.assetListWithExtraFields);
  //   this.loading=false;
  //   },
  // (err)=>{
  //   console.log(err);
  //   this.loading=false;
  // })

  this.advanceFilterFunc();

    }

    showFilter(){
    
      this.filterShow= !this.filterShow;
    }
  
    // addFilter(){

    //   this.filterForm.addControl(this.selectFilter,this.formBuilder.control(''));
    //   console.log(this.selectFilter);
    //     if(this.selectFilter!=""){
    //     this.selectedFilterList.push(this.selectFilter);
    //     console.log(this.selectedFilterList);
    //     const index=this.filterList.indexOf(this.selectFilter);
    //     this.filterList = this.filterList.filter((item: string) => item !== this.selectFilter);

   
        

    //   }
    //   this.selectFilter="";
    
    // }
    

    removeInputField(name: any) {

      console.log("remover"+name)
      this.filterForm.removeControl(name);
      // this.filterList.push(name);
      this.selectedFilterList = this.selectedFilterList.filter((item: string) => item !== name);
      console.log("selectedFilterList-"+this.selectedFilterList)
     
      console.log(this.filterForm.value);
    }
    removeMandatoryFieldFilter(name:any){
      this.filterForm.removeControl(name);
      this.mandatoryFieldFilterList.set(name,false);
    }
    addFilterForm(){
      this.loading=true;
      console.log(this.filterForm.value);
      this.mandatoryFieldFilterList.forEach((value,data)=>{
        if(value==true&&this.filterForm.controls[data]?.value!=null&&this.filterForm.controls[data]?.value!=""){
          
          this.appliedFilterListMap.set(data,this.filterForm.get(data)?.value);
          this.appliedFilterList.add(data);
        }
      })
      
      this.selectedFilterList.forEach((name: string)=>{
        if(this.filterForm.controls[name].value!=null&&this.filterForm.controls[name].value!=""){
        this.appliedFilterListMap.set(name,this.filterForm.get(name)?.value);
        this.appliedFilterList.add(name);
        }
      })
      console.log("applied filter"+this.appliedFilterList);
      this.advanceFilterFunc();

    }

    removeSingleFilter(name:string){
      console.log("single: "+name)
      this.appliedFilterList.delete(name);
  
      this.filterForm.get(name)?.setValue(null);


    this.advanceFilterFunc();

    }
    reset(){
      this.loading=true;
      this.filterForm.reset();
      this.sortedBy="";
      this.searchData=null;
      this.appliedFilterList=new Set<string>();
      this.appliedFilterListMap=new Map<string,string>;
      this.filterForm.controls['email'].setValue(this.email);
      this.filterForm.controls['companyId'].setValue(this.companyId);
      this.myList.forEach((field)=>{
        this.mandatoryFieldFilterList.set(field,true);
        this.filterForm.addControl(field,this.formBuilder.control('',Validators.required));
      });
      this.selectedFilterList=[];
      this.showFieldsList.forEach((x)=>{
       
        this.selectedFilterList.push(x.name);
        this.filterForm.addControl(x.name,this.formBuilder.control('',Validators.required));
        this.showFieldsMap.set(x.name,x.show);
       
      })
      // this.assetService.advanceFilter(this.filterForm.value,this.pageIndex,this.pageSize,this.sortedBy).subscribe((data)=>{
      //   console.log(data);
      //   this.assetListWithExtraFields=[]
      // this.paginationResult=data;
      // this.totalLength=this.paginationResult.totalRecords;
      // this.assets=this.paginationResult.data;
      // const jsonList:string[]=this.paginationResult.data;
      // jsonList.forEach((workorder)=>{
      //   const jsonObject:any = JSON.parse(workorder);
      //   console.log(typeof(jsonObject))
      //   this.assetListWithExtraFields.push(jsonObject)
      // })
      // console.log(this.assetListWithExtraFields);
      // this.loading=false;
      // })

      this.advanceFilterFunc();
    }
    mandatoryFieldCheckBox(isChecked:any,item:string){
     
      if(isChecked){
        this.showMandatoryBasicFields.set(item,true);
      }
      else{
        this.showMandatoryBasicFields.set(item,false);
      }
      const myArry:any=[];
      this.showMandatoryBasicFields.forEach((val,ele)=>{
        if(val==true){
        myArry.push(ele)
        }
      })
      // console.log(JSON.stringify(Object.fromEntries(this.showMandatoryBasicFields)));
      localStorage.setItem("showMandatoryBasicFieldsAssets",  JSON.stringify(myArry));
      console.log(item+" mandatory-"+localStorage.getItem("showMandatoryBasicFieldsAssets"));
    }



    customCheckBox(isChecked:any,item:string){
      console.log(isChecked);
     
      if(isChecked){
        this.selectedExtraColums.push(item);
        this.selectedExtraColumsMap.set(item,true);
      }
      else{
        this.selectedExtraColums=this.selectedExtraColums.filter((data)=> data!=item);
        this.selectedExtraColumsMap?.set(item,false);
      }
       localStorage.setItem("selectedExtraColumsAssets",  JSON.stringify(this.selectedExtraColums));
      console.log(this.selectedExtraColums);
    }
    onKeyDown(event: KeyboardEvent): void {
      if (event.key === 'Enter') {
        this.onSearch();
      }
    }
    openSnackBar(message: string, action: string) {
      this._snackBar.open(message, action);
    }

}