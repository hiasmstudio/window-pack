unit MSCryptoAPI;

interface

uses
  Windows;

//  Constants for HiAsm Componets
const
  NO_ERROR                  =   0;
  ERROR_INVALID_PARAMETER   =   1;
  ERROR_ACQUIRE_CONTEXT     =   2;
  ERROR_GENERATION_KEY      =   3;
  ERROR_GENERATION_KEYPAIR  =   4;
  ERROR_GET_USER_KEY        =   5;
  ERROR_DERIVE_KEY          =   6;
  ERROR_ENCRYPT             =   7;
  ERROR_DECRYPT             =   8;
  ERROR_CREATE_HASH         =   9;
  ERROR_HASH_DATA           =  10;
  ERROR_GET_HASH_PARAM      =  11;
  ERROR_SIGNED_HASH         =  12;
  ERROR_EXPORT_KEYPAIR      =  13;
  ERROR_EXPORT_PUBLICKEY    =  14;
  ERROR_EXPORT_SESSIONKEY   =  15;
  ERROR_EXPORT_EXCHANGEKEY  =  16;
  ERROR_IMPORT_KEYPAIR      =  17;
  ERROR_IMPORT_PUBLICKEY    =  18;
  ERROR_IMPORT_SESSIONKEY   =  19;
  ERROR_IMPORT_EXCHANGEKEY  =  20;

type
  HCRYPTPROV  = Cardinal;
  HCRYPTKEY   = Cardinal;
  ALG_ID      = Cardinal;
  PHCRYPTPROV = ^HCRYPTPROV;
  PHCRYPTKEY  = ^HCRYPTKEY;
  HCRYPTHASH  = Cardinal;
  PHCRYPTHASH = ^HCRYPTHASH;
  PLongWord   = ^LongWord;
  
const
  ADVAPI32            = 'advapi32.dll';

  RSA384BIT_KEY       = $01800000;
  RSA512BIT_KEY       = $02000000;
  RSA1024BIT_KEY      = $04000000;
  RSA2048BIT_KEY      = $08000000;
  RSA4096BIT_KEY      = $10000000;
//  RSA8192BIT_KEY      = $20000000;
//  RSA16384BIT_KEY     = $40000000;

  // exported key blob definitions
  SIMPLEBLOB          = $1;
  PUBLICKEYBLOB       = $6;
  PRIVATEKEYBLOB      = $7;
  PLAINTEXTKEYBLOB    = $8;

  AT_KEYEXCHANGE      = 1;
  AT_SIGNATURE        = 2;

  CRYPT_USERDATA      = 1;

  CRYPT_BLOB_VER3     = $00000080;

  CALG_MD2            = 32769;
  CALG_MD4            = 32770;
  CALG_MD5            = 32771;
  CALG_SHA            = 32772;
  CALG_SHA_1          = 32772;
  CALG_SHA_256        = 32780;
  CALG_SHA_384        = 32781;
  CALG_SHA_512        = 32782;
  CALG_RC2            = 26114;
  CALG_RC4            = 26625;
  CALG_RC5            = 26125;
  CALG_DES            = 26113;
  CALG_3DES_112       = 26121;
  CALG_3DES           = 26115;
  CALG_DESX           = 26116;
  CALG_AES            = 26129;
  CALG_AES_128        = 26126;
  CALG_AES_192        = 26127;
  CALG_AES_256        = 26128;
  CALG_CYLINK_MEK     = 26124;
  CALG_RSA_KEYX       = 41984;
  CALG_RSA_SIGN       = 9216;

  HP_ALGID            = $0001; // Hash algorithm
  HP_HASHVAL          = $0002; // Hash value
  HP_HASHSIZE         = $0004; // Hash value size

  // dwFlags definitions for CryptAcquireContext
  CRYPT_VERIFYCONTEXT  = $F0000000;
  CRYPT_NEWKEYSET      = $00000008;
  CRYPT_DELETEKEYSET   = $00000010;
  CRYPT_MACHINE_KEYSET = $00000020;

  // dwFlag definitions for CryptGenKey
  CRYPT_EXPORTABLE     = $00000001;
  CRYPT_USER_PROTECTED = $00000002;
  CRYPT_CREATE_SALT    = $00000004;
  CRYPT_UPDATE_KEY     = $00000008;
  CRYPT_NO_SALT        = $00000010;
  CRYPT_PREGEN         = $00000040;
  CRYPT_RECIPIENT      = $00000010;
  CRYPT_INITIATOR      = $00000040;
  CRYPT_ONLINE         = $00000080;
  CRYPT_SF             = $00000100;
  CRYPT_CREATE_IV      = $00000200;
  CRYPT_KEK            = $00000400;
  CRYPT_DATA_KEY       = $00000800;

  // dwFlags definitions for CryptDeriveKey
  CRYPT_SERVER         = $00000400;

  PROV_RSA_FULL         = 1;
  PROV_RSA_SIG          = 2;
  PROV_DSS              = 3;
  PROV_FORTEZZA         = 4;
  PROV_MS_EXCHANGE      = 5;
  PROV_SSL              = 6;
  PROV_RSA_SCHANNEL     = 12;
  PROV_DSS_DH           = 13;
  PROV_EC_ECDSA_SIG     = 14;
  PROV_EC_ECNRA_SIG     = 15;
  PROV_EC_ECDSA_FULL    = 16;
  PROV_EC_ECNRA_FULL    = 17;
  PROV_DH_SCHANNEL      = 18;
  PROV_SPYRUS_LYNKS     = 20;
  PROV_RNG              = 21;
  PROV_INTEL_SEC        = 22;
  PROV_REPLACE_OWF      = 23;
  PROV_RSA_AES          = 24;

  MS_DEF_DH_SCHANNEL_PROV   = 'Microsoft DH Schannel Cryptographic Provider';
  MS_DEF_DSS_DH_PROV        = 'Microsoft Base DSS and Diffie-Hellman Cryptographic Provider';
  MS_DEF_DSS_PROV           = 'Microsoft Base DSS Cryptographic Provider';
  MS_DEF_PROV               = 'Microsoft Base Cryptographic Provider v1.0';
  MS_DEF_RSA_SCHANNEL_PROV  = 'Microsoft RSA Schannel Cryptographic Provider';
  MS_DEF_RSA_SIG_PROV       = 'Microsoft RSA Signature Cryptographic Provider';
  MS_ENH_DSS_DH_PROV        = 'Microsoft Enhanced DSS and Diffie-Hellman Cryptographic Provider';
  MS_ENH_RSA_AES_PROV       = 'Microsoft Enhanced RSA and AES Cryptographic Provider';
  MS_ENHANCED_PROV          = 'Microsoft Enhanced Cryptographic Provider v1.0';
  MS_SCARD_PROV             = 'Microsoft Base Smart Card Crypto Provider';
  MS_STRONG_PROV            = 'Microsoft Strong Cryptographic Provider';

function CryptAcquireContext(Prov: PHCRYPTPROV; Container: PChar; Provider: PChar; ProvType: LongWord; Flags: LongWord): LongBool; stdcall; external ADVAPI32 name 'CryptAcquireContextA';
function CryptGenKey(hProv: HCRYPTPROV; Algid: ALG_ID; dwFlags: LongWord; phKey: PHCRYPTKEY): LongBool; stdcall; external ADVAPI32 name 'CryptGenKey';
function CryptGetUserKey(hProv: HCRYPTPROV; dwKeySpec: LongWord; phUserKey: PHCRYPTKEY): LongBool; stdcall; external ADVAPI32 name 'CryptGetUserKey';
function CryptDeriveKey(Prov: HCRYPTPROV; Algid: ALG_ID; BaseData: HCRYPTHASH; Flags: LongWord; Key: PHCRYPTKEY): LongBool; stdcall; external ADVAPI32 name 'CryptDeriveKey';
function CryptExportKey(hKey: HCRYPTKEY; hExpKey: HCRYPTKEY; dwBlobType: LongWord; dwFlags: LongWord; pbData: PChar; pdwDataLen: PLongWord): LongBool; stdcall; external ADVAPI32 name 'CryptExportKey';
function CryptImportKey(hProv: HCRYPTPROV; pbData: PChar; dwDataLen: LongWord; hPubKey: HCRYPTKEY; dwFlags: LongWord; phKey: PHCRYPTKEY):LongBool; stdcall; external ADVAPI32 name 'CryptImportKey';

function CryptEncrypt(Key: HCRYPTKEY; Hash: HCRYPTHASH; Final: LongBool; Flags: LongWord; Data: PChar; Len: PLongWord; BufLen: LongWord): LongBool;stdcall;external ADVAPI32 name 'CryptEncrypt';
function CryptDecrypt(Key: HCRYPTKEY; Hash: HCRYPTHASH; Final: LongBool; Flags: LongWord; Data: PChar; Len: PLongWord): LongBool; stdcall; external ADVAPI32 name 'CryptDecrypt';

function CryptCreateHash(Prov: HCRYPTPROV; Algid: ALG_ID; Key: HCRYPTKEY; Flags: LongWord; Hash: PHCRYPTHASH): LongBool; stdcall; external ADVAPI32 name 'CryptCreateHash';
function CryptHashData(Hash: HCRYPTHASH; Data: PChar; DataLen: LongWord; Flags: LongWord): LongBool; stdcall; external ADVAPI32 name 'CryptHashData';
function CryptGetHashParam(hHash: HCRYPTHASH; dwParam: LongWord; pbData: PChar; pdwDataLen: PLongWord; dwFlags: LongWord): LongBool; stdcall; external ADVAPI32 name 'CryptGetHashParam';
function CryptSignHash(hHash: HCRYPTHASH; dwKeySpec: LongWord; sDescription: PAnsiChar; dwFlags: LongWord; pbSignature: PChar; pdwSigLen: PLongWord): LongBool; stdcall; external ADVAPI32 name 'CryptSignHashA';
function CryptVerifySignature(hHash: HCRYPTHASH; const pbSignature: PChar; dwSigLen: LongWord; hPubKey: HCRYPTKEY; sDescription: PAnsiChar; dwFlags: LongWord): LongBool; stdcall; external ADVAPI32 name 'CryptVerifySignatureA';

function CryptReleaseContext(hProv: HCRYPTPROV; dwFlags: LongWord): LongBool; stdcall; external ADVAPI32 name 'CryptReleaseContext';
function CryptDestroyHash(hHash: HCRYPTHASH): LongBool; stdcall; external ADVAPI32 name 'CryptDestroyHash';
function CryptDestroyKey(hKey: HCRYPTKEY): LongBool; stdcall; external ADVAPI32 name 'CryptDestroyKey';

implementation
end.