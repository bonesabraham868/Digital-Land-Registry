import { describe, expect, it } from "vitest";
import { Cl } from "@stacks/transactions";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;
const address3 = accounts.get("wallet_3")!;
const contractOwner = accounts.get("deployer")!;

describe("Digital Land Registry - Property Registration", () => {
  it("ensures simnet is well initialised", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("can register a new property", () => {
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "register-property",
      [
        Cl.stringAscii("123 Main Street"),
        Cl.uint(1000),
        Cl.stringAscii("Residential"),
        Cl.stringAscii("deed-hash-123"),
        Cl.stringAscii("survey-hash-456"),
        Cl.stringAscii("Single family home on Main Street"),
        Cl.stringAscii("Residential"),
        Cl.stringAscii("TAX-001")
      ],
      address1
    );
    expect(result).toBeUint(1);
  });
});

describe("Digital Land Registry - Insurance System", () => {
  // Helper function to register a property for testing
  const registerTestProperty = (owner: string, propertyId: number = 1) => {
    return simnet.callPublicFn(
      "Digital-Land-Registry",
      "register-property",
      [
        Cl.stringAscii(`${propertyId} Test Street`),
        Cl.uint(1000),
        Cl.stringAscii("Residential"),
        Cl.stringAscii(`deed-hash-${propertyId}`),
        Cl.stringAscii(`survey-hash-${propertyId}`),
        Cl.stringAscii(`Test property ${propertyId}`),
        Cl.stringAscii("Residential"),
        Cl.stringAscii(`TAX-00${propertyId}`)
      ],
      owner
    );
  };

  it("can create insurance policy for registered property", () => {
    // First register a property
    registerTestProperty(address1);

    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [
        Cl.uint(1), // property-id
        Cl.stringAscii("TestInsurance Co"), // provider
        Cl.uint(50000000), // coverage-amount (50 STX)
        Cl.uint(1000000), // premium-amount (1 STX)
        Cl.uint(8760) // policy-duration (1 year in blocks)
      ],
      address1
    );
    expect(result).toBeUint(1); // Should return policy ID
  });

  it("cannot create policy with invalid coverage amount", () => {
    registerTestProperty(address1);

    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [
        Cl.uint(1), // property-id
        Cl.stringAscii("TestInsurance Co"), // provider
        Cl.uint(0), // invalid coverage-amount
        Cl.uint(1000000), // premium-amount
        Cl.uint(8760) // policy-duration
      ],
      address1
    );
    expect(result).toBeErr(Cl.uint(306)); // ERR_INVALID_COVERAGE_AMOUNT
  });

  it("can get insurance policy details", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [
        Cl.uint(1),
        Cl.stringAscii("TestInsurance Co"),
        Cl.uint(50000000),
        Cl.uint(1000000),
        Cl.uint(8760)
      ],
      address1
    );

    const { result } = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-insurance-policy",
      [Cl.uint(1), Cl.uint(1)], // property-id, policy-id
      address1
    );
    expect(result).toBeSome();
  });

  it("can submit insurance claim", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [
        Cl.uint(1),
        Cl.stringAscii("TestInsurance Co"),
        Cl.uint(50000000),
        Cl.uint(1000000),
        Cl.uint(8760)
      ],
      address1
    );

    // Submit claim
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "submit-insurance-claim",
      [
        Cl.uint(1), // property-id
        Cl.uint(1), // policy-id
        Cl.uint(25000000), // claim-amount (25 STX)
        Cl.stringAscii("Fire damage to kitchen") // claim-reason
      ],
      address1
    );
    expect(result).toBeUint(1); // Should return claim ID
  });

  it("can process insurance claim - approval", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [
        Cl.uint(1),
        Cl.stringAscii("TestInsurance Co"),
        Cl.uint(50000000),
        Cl.uint(1000000),
        Cl.uint(8760)
      ],
      address1
    );

    // Submit claim
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "submit-insurance-claim",
      [
        Cl.uint(1),
        Cl.uint(1),
        Cl.uint(25000000),
        Cl.stringAscii("Fire damage to kitchen")
      ],
      address1
    );

    // Process claim (approve)
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "process-insurance-claim",
      [
        Cl.uint(1), // property-id
        Cl.uint(1), // claim-id
        Cl.bool(true), // approved
        Cl.some(Cl.uint(25000000)) // approved-amount
      ],
      contractOwner
    );
    expect(result).toBeOk(Cl.bool(true));
  });

  it("can cancel insurance policy", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [
        Cl.uint(1),
        Cl.stringAscii("TestInsurance Co"),
        Cl.uint(50000000),
        Cl.uint(1000000),
        Cl.uint(8760)
      ],
      address1
    );

    // Cancel policy
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "cancel-insurance-policy",
      [Cl.uint(1), Cl.uint(1)], // property-id, policy-id
      address1
    );
    expect(result).toBeOk(Cl.bool(true));
  });

  it("can get policy count", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [
        Cl.uint(1),
        Cl.stringAscii("TestInsurance Co"),
        Cl.uint(50000000),
        Cl.uint(1000000),
        Cl.uint(8760)
      ],
      address1
    );

    const { result } = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-policy-count",
      [],
      address1
    );
    expect(result).toBeUint(1);
  });
});
