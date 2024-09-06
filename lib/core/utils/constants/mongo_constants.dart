// user = "varunwahi";
// password = "W1kUtmuipJAv3Gro"

// ignore_for_file: constant_identifier_names

//DATABASE CONNECTION URLS
const MONGO_CONN_URL = "mongodb+srv://varunwahi:W1kUtmuipJAv3Gro@assetmonk.0nc1dz0.mongodb.net/asset_monk?retryWrites=true&w=majority";
const CUSTOMER_DB_CONN_URL = "mongodb+srv://varunwahi:W1kUtmuipJAv3Gro@assetmonk.0nc1dz0.mongodb.net/QuantamMaintenanceCustomer?retryWrites=true&w=majority";
const ASSETS_DB_CONN_URL = "mongodb+srv://varunwahi:W1kUtmuipJAv3Gro@assetmonk.0nc1dz0.mongodb.net/QuantamMaintenanceAssets?retryWrites=true&w=majority";
const WO_DB_CONN_URL = "mongodb+srv://varunwahi:W1kUtmuipJAv3Gro@assetmonk.0nc1dz0.mongodb.net/QuantamMaintenanceWorkOrder?retryWrites=true&w=majority";


//COLLECTIONS IN ASSETS DB
const ASSETS_COLLECTION = "assets";
const ASSET_FILES_COLLECTION = "assetFile";
const ASSET_CHECKINOUT_COLLECTION = "checkInOut";
const ASSET_EXTRA_FIELD_NAMES_COLLECTION = "extraFieldNames";
const ASSET_EXTRA_FIELDS_COLLECTION = "extraFields";
const ASSET_MANDATORY_COLLECTION = "mandatoryFields";
const ASSET_QR_CODE_COLLECTION = "qr";
const ASSET_SHOW_FIELDS_COLLECTION = "showFields";


//COLLECTIONS IN WORKD ORDERS DB
const WO_COLLECTION = "workOrder"; //WORK ORDERS COLLECTION NAME
const WO_SHOW_FIELDS_COLLECTION = "showFields"; //WO SHOW FIELDS COLLECTION NAME
const WO_EXTRA_FIELDS_COLLECTION = "extraFields"; //WO EXTRA FIELDS COLLECTION NAME

//OTHER COLLECTIONS

const INVENTORY_COLLECTION = "Inventory"; // INVENTORY COLLECTION NAME
const CUSTOMER_COLLECTION = "customer"; // INVENTORY COLLECTION NAME
const CUSTOMER_EXTRA_FIELD_NAMES_COLLECTION = "extraFieldNames";

const COMPANY_COLLECTION = "companyInformation"; // INVENTORY COLLECTION NAME
// const USER_COLLECTION = "work_orders"; //WORK ORDERS COLLECTION NAME

