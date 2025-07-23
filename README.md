# 🏠 Digital Land Registry Smart Contract

A comprehensive blockchain-based land registry system built with Clarity for the Stacks blockchain. This smart contract enables secure property registration, ownership transfer, marketplace functionality, and property verification.

## 🌟 Features

- **🏡 Property Registration**: Register land properties with detailed metadata
- **📋 Ownership Management**: Transfer property ownership securely
- **💰 Marketplace**: List properties for sale and purchase them
- **✅ Verification System**: Request and approve property verifications
- **📊 Transaction History**: Track all property transactions
- **👤 User Portfolio**: View all properties owned by a user
- **💳 Fee Management**: Configurable registry and transfer fees

## 🚀 Getting Started

### Prerequisites
- [Clarinet](https://docs.hiro.so/clarinet) installed
- Node.js and npm for testing

### Installation
```bash
git clone <repository-url>
cd Digital-Land-Registry
clarinet check
```

## 🔧 Contract Functions

### 📝 Registration Functions

#### `register-property`
Register a new property in the land registry.

```clarity
(register-property 
  "123 Main St, City" 
  u1000 
  "Residential" 
  "deed-hash-123" 
  "survey-hash-456" 
  "Legal description here" 
  "Residential" 
  "TAX-ID-789"
)
```

**Parameters:**
- `location`: Property address (string, max 100 chars)
- `size`: Property size in square meters
- `property-type`: Type of property (string, max 50 chars)
- `title-deed-hash`: Hash of title deed document
- `survey-hash`: Hash of survey document
- `legal-description`: Legal description (string, max 200 chars)
- `zoning`: Zoning classification
- `tax-id`: Tax identification number

### 🔄 Transfer Functions

#### `transfer-property`
Transfer ownership of a property to another user.

```clarity
(transfer-property u1 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

#### `purchase-property`
Purchase a property that's listed for sale.

```clarity
(purchase-property u1)
```

### 🏪 Marketplace Functions

#### `list-property-for-sale`
List a property for sale at a specified price.

```clarity
(list-property-for-sale u1 u50000000)  ;; Price in microSTX
```

#### `remove-property-from-sale`
Remove a property from the marketplace.

```clarity
(remove-property-from-sale u1)
```

### 📈 Management Functions

#### `update-market-value`
Update the estimated market value of a property.

```clarity
(update-market-value u1 u55000000)
```

#### `request-verification`
Request official verification of a property.

```clarity
(request-verification u1)
```

#### `verify-property` (Owner Only)
Approve a property verification request.

```clarity
(verify-property u1)
```

## 📊 Read-Only Functions

### Property Information
- `get-property`: Get detailed property information
- `get-property-metadata`: Get property metadata
- `get-user-properties`: Get all properties owned by a user
- `get-property-history`: Get transaction history for a property
- `get-verification-request`: Get verification status

### Contract Settings
- `get-registry-fee`: Current registration fee
- `get-transfer-fee-percent`: Current transfer fee percentage
- `get-property-count`: Total number of registered properties

## 💰 Fee Structure

- **Registration Fee**: 1 STX (configurable)
- **Transfer Fee**: 2% of sale price (configurable, max 10%)

## 🔒 Access Control

- **Property Owners**: Can transfer, list for sale, update market value, request verification
- **Contract Owner**: Can verify properties, adjust fees
- **Public**: Can view property information and purchase listed properties

## 📱 Usage Examples

### Register a New Property
```bash
clarinet console
(contract-call? .Digital-Land-Registry register-property 
  "456 Oak Avenue, Springfield" 
  u1500 
  "Commercial" 
  "abc123deed" 
  "xyz789survey" 
  "Commercial lot on Oak Avenue" 
  "Commercial" 
  "COM-2023-001"
)
```

### List Property for Sale
```bash
(contract-call? .Digital-Land-Registry list-property-for-sale u1 u75000000)
```

### Purchase Property
```bash
(contract-call? .Digital-Land-Registry purchase-property u1)
```

## 🧪 Testing

Run the test suite:
```bash
npm install
npm test
```

## 📊 Data Structures

The contract maintains several key data maps:

- **properties**: Core property information
- **property-metadata**: Legal documents and metadata
- **user-properties**: User ownership mapping
- **property-history**: Transaction history
- **verification-requests**: Verification status tracking

## 🛡️ Security Features

- ✅ Ownership verification for all property operations
- ✅ Input validation and error handling
- ✅ Safe arithmetic operations
- ✅ Access control for administrative functions
- ✅ Transaction history immutability

## 🚨 Error Codes

- `u100`: Not authorized
- `u101`: Property not found
- `u102`: Property already exists
- `u103`: Not property owner
- `u104`: Invalid price
- `u105`: Insufficient funds
- `u106`: Property not for sale
- `u107`: Cannot buy own property
- `u108`: Transfer failed


## 📄 License

This project is licensed under the MIT License.

## 🙋‍♂️ Support

For questions or support, please open an issue in the repository.

---

Built with ❤️ for the Stacks ecosystem 🔗
