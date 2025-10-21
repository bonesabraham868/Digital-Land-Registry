
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

  it("can get registered property details", () => {
    // First register a property
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "register-property",
      [
        Cl.stringAscii("456 Oak Avenue"),
        Cl.uint(1500),
        Cl.stringAscii("Commercial"),
        Cl.stringAscii("deed-hash-456"),
        Cl.stringAscii("survey-hash-789"),
        Cl.stringAscii("Commercial building on Oak Avenue"),
        Cl.stringAscii("Commercial"),
        Cl.stringAscii("TAX-002")
      ],
      address1
    );

    const { result } = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-property",
      [Cl.uint(1)],
      address1
    );
    expect(result).toBeSome();
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
        1, // property-id
        "TestInsurance Co", // provider
        0, // invalid coverage-amount
        1000000, // premium-amount
        8760 // policy-duration
      ],
      address1
    );
    expect(result).toBeErr(306); // ERR_INVALID_COVERAGE_AMOUNT
  });

  it("cannot create policy for property not owned", () => {
    registerTestProperty(address1);

    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [
        1, // property-id
        "TestInsurance Co", // provider
        50000000, // coverage-amount
        1000000, // premium-amount
        8760 // policy-duration
      ],
      address2 // Different owner
    );
    expect(result).toBeErr(103); // ERR_NOT_OWNER
  });

  it("cannot create duplicate active policy", () => {
    registerTestProperty(address1);
    
    // Create first policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    // Try to create another active policy
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "AnotherInsurance Co", 60000000, 1200000, 8760],
      address1
    );
    expect(result).toBeErr(303); // ERR_INSURANCE_ALREADY_EXISTS
  });

  it("can get insurance policy details", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    const { result } = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-insurance-policy",
      [1, 1], // property-id, policy-id
      address1
    );
    expect(result).toBeSome();
  });

  it("can check if policy is active", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    const { result } = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "is-policy-active",
      [1, 1], // property-id, policy-id
      address1
    );
    expect(result).toBeBool(true);
  });

  it("can get policy coverage amount", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    const { result } = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-policy-coverage",
      [1, 1], // property-id, policy-id
      address1
    );
    expect(result).toBeSome();
  });

  it("can renew insurance policy", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    // Renew policy
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "renew-insurance-policy",
      [
        1, // property-id
        1, // policy-id
        60000000, // new-coverage-amount
        1200000, // new-premium-amount
        8760 // policy-duration
      ],
      address1
    );
    expect(result).toBeOk(true);
  });

  it("can submit insurance claim", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    // Submit claim
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "submit-insurance-claim",
      [
        1, // property-id
        1, // policy-id
        25000000, // claim-amount (25 STX)
        "Fire damage to kitchen" // claim-reason
      ],
      address1
    );
    expect(result).toBeUint(1); // Should return claim ID
  });

  it("cannot submit claim exceeding coverage amount", () => {
    registerTestProperty(address1);
    
    // Create policy with 50 STX coverage
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    // Try to submit claim for 100 STX (exceeds coverage)
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "submit-insurance-claim",
      [
        1, // property-id
        1, // policy-id
        100000000, // claim-amount (100 STX - exceeds 50 STX coverage)
        "Major structural damage" // claim-reason
      ],
      address1
    );
    expect(result).toBeErr(306); // ERR_INVALID_COVERAGE_AMOUNT
  });

  it("can process insurance claim - approval", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    // Submit claim
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "submit-insurance-claim",
      [1, 1, 25000000, "Fire damage to kitchen"],
      address1
    );

    // Process claim (approve)
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "process-insurance-claim",
      [
        1, // property-id
        1, // claim-id
        true, // approved
        25000000 // approved-amount
      ],
      contractOwner
    );
    expect(result).toBeOk(true);
  });

  it("can process insurance claim - rejection", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    // Submit claim
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "submit-insurance-claim",
      [1, 1, 25000000, "Suspicious claim"],
      address1
    );

    // Process claim (reject)
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "process-insurance-claim",
      [
        1, // property-id
        1, // claim-id
        false, // approved = false
        null // approved-amount (none for rejection)
      ],
      contractOwner
    );
    expect(result).toBeOk(true);
  });

  it("cannot process claim if not contract owner", () => {
    registerTestProperty(address1);
    
    // Create policy and submit claim
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );
    
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "submit-insurance-claim",
      [1, 1, 25000000, "Test claim"],
      address1
    );

    // Try to process claim as non-owner
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "process-insurance-claim",
      [1, 1, true, 25000000],
      address2 // Not contract owner
    );
    expect(result).toBeErr(100); // ERR_NOT_AUTHORIZED
  });

  it("can record premium payment", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    // Record premium payment
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "record-premium-payment",
      [
        1, // property-id
        1, // policy-id
        "Q1-2024" // period-covered
      ],
      address1
    );
    expect(result).toBeUint(2); // Should return payment ID (2 because initial payment is 1)
  });

  it("can cancel insurance policy", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    // Cancel policy
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "cancel-insurance-policy",
      [1, 1], // property-id, policy-id
      address1
    );
    expect(result).toBeOk(true);
  });

  it("can get insurance claim details", () => {
    registerTestProperty(address1);
    
    // Create policy and submit claim
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );
    
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "submit-insurance-claim",
      [1, 1, 25000000, "Test claim for details"],
      address1
    );

    const { result } = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-insurance-claim",
      [1, 1], // property-id, claim-id
      address1
    );
    expect(result).toBeSome();
  });

  it("can get premium payment details", () => {
    registerTestProperty(address1);
    
    // Create policy (this creates initial payment)
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );

    const { result } = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-premium-payment",
      [1, 1, 1], // property-id, policy-id, payment-id
      address1
    );
    expect(result).toBeSome();
  });

  it("can get policy, claim, and payment counts", () => {
    registerTestProperty(address1);
    
    // Create policy
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "create-insurance-policy",
      [1, "TestInsurance Co", 50000000, 1000000, 8760],
      address1
    );
    
    // Submit claim
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "submit-insurance-claim",
      [1, 1, 25000000, "Test claim"],
      address1
    );
    
    // Record additional payment
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "record-premium-payment",
      [1, 1, "Q2-2024"],
      address1
    );

    // Check counts
    const policyCount = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-policy-count",
      [],
      address1
    );
    expect(policyCount.result).toBeUint(1);

    const claimCount = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-claim-count",
      [],
      address1
    );
    expect(claimCount.result).toBeUint(1);

    const paymentCount = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-payment-count",
      [],
      address1
    );
    expect(paymentCount.result).toBeUint(2); // Initial + additional payment
  });
});
