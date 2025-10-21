import { describe, expect, it } from "vitest";
import { Cl } from "@stacks/transactions";

const accounts = simnet.getAccounts();
const address1 = accounts.get("wallet_1")!;
const address2 = accounts.get("wallet_2")!;
const contractOwner = accounts.get("deployer")!;

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

// Helper to create a 32-byte buffer hash
const createDocHash = (value: string): Uint8Array => {
  const hash = new Uint8Array(32);
  const encoded = new TextEncoder().encode(value);
  hash.set(encoded.slice(0, 32));
  return hash;
};

describe("Property Document Registry", () => {
  it("ensures simnet is well initialized", () => {
    expect(simnet.blockHeight).toBeDefined();
  });

  it("can add document to registered property by owner", () => {
    // First register a property
    const registerResult = registerTestProperty(address1);
    expect(registerResult.result).toBeOk(Cl.uint(1));

    // Add a document
    const docHash = createDocHash("test-document-hash-1");
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1), // property-id
        Cl.buffer(docHash), // doc-hash
        Cl.stringAscii("deed"), // doc-type
        Cl.stringAscii("https://example.com/document1.pdf") // uri
      ],
      address1
    );
    
    expect(result).toBeOk(Cl.uint(1)); // Should return doc-id 1
  });

  it("can retrieve added document details", () => {
    // Register property and add document
    registerTestProperty(address1);
    const docHash = createDocHash("test-document-hash-2");
    
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1),
        Cl.buffer(docHash),
        Cl.stringAscii("survey"),
        Cl.stringAscii("https://example.com/survey1.pdf")
      ],
      address1
    );

    // Get the document
    const { result } = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-document",
      [Cl.uint(1), Cl.uint(1)], // property-id, doc-id
      address1
    );
    
    expect(result).toBeDefined();
  });

  it("prevents non-owner from adding document", () => {
    // Register property with address1
    registerTestProperty(address1);
    
    // Try to add document with address2 (not owner)
    const docHash = createDocHash("test-document-hash-3");
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1),
        Cl.buffer(docHash),
        Cl.stringAscii("certificate"),
        Cl.stringAscii("https://example.com/cert1.pdf")
      ],
      address2
    );
    
    expect(result).toBeErr(Cl.uint(401)); // ERR_DOC_NOT_PROPERTY_OWNER
  });

  it("prevents adding document to non-existent property", () => {
    const docHash = createDocHash("test-document-hash-4");
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(999), // non-existent property-id
        Cl.buffer(docHash),
        Cl.stringAscii("deed"),
        Cl.stringAscii("https://example.com/document2.pdf")
      ],
      address1
    );
    
    expect(result).toBeErr(Cl.uint(402)); // ERR_DOC_PROPERTY_NOT_FOUND
  });

  it("prevents duplicate document hash for same property", () => {
    // Register property and add first document
    registerTestProperty(address1);
    const docHash = createDocHash("duplicate-hash");
    
    // Add first document successfully
    const firstResult = simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1),
        Cl.buffer(docHash),
        Cl.stringAscii("deed"),
        Cl.stringAscii("https://example.com/doc1.pdf")
      ],
      address1
    );
    expect(firstResult.result).toBeOk(Cl.uint(1));
    
    // Try to add same hash again
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1),
        Cl.buffer(docHash),
        Cl.stringAscii("survey"),
        Cl.stringAscii("https://example.com/doc2.pdf")
      ],
      address1
    );
    
    expect(result).toBeErr(Cl.uint(403)); // ERR_DOC_EXISTS
  });

  it("can revoke document by owner", () => {
    // Register property and add document
    registerTestProperty(address1);
    const docHash = createDocHash("revokable-document");
    
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1),
        Cl.buffer(docHash),
        Cl.stringAscii("deed"),
        Cl.stringAscii("https://example.com/revokable.pdf")
      ],
      address1
    );
    
    // Revoke the document
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "revoke-document",
      [
        Cl.uint(1), // property-id
        Cl.uint(1)  // doc-id
      ],
      address1
    );
    
    expect(result).toBeOk(Cl.bool(true));
  });

  it("prevents non-owner from revoking document", () => {
    // Register property and add document with address1
    registerTestProperty(address1);
    const docHash = createDocHash("non-owner-revoke-test");
    
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1),
        Cl.buffer(docHash),
        Cl.stringAscii("deed"),
        Cl.stringAscii("https://example.com/test.pdf")
      ],
      address1
    );
    
    // Try to revoke with address2 (not owner)
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "revoke-document",
      [
        Cl.uint(1), // property-id
        Cl.uint(1)  // doc-id
      ],
      address2
    );
    
    expect(result).toBeErr(Cl.uint(401)); // ERR_DOC_NOT_PROPERTY_OWNER
  });

  it("prevents revoking non-existent document", () => {
    registerTestProperty(address1);
    
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "revoke-document",
      [
        Cl.uint(1), // property-id
        Cl.uint(999) // non-existent doc-id
      ],
      address1
    );
    
    expect(result).toBeErr(Cl.uint(404)); // ERR_DOC_NOT_FOUND
  });

  it("prevents revoking already revoked document", () => {
    // Register property and add document
    registerTestProperty(address1);
    const docHash = createDocHash("already-revoked-test");
    
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1),
        Cl.buffer(docHash),
        Cl.stringAscii("deed"),
        Cl.stringAscii("https://example.com/revoked.pdf")
      ],
      address1
    );
    
    // First revoke
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "revoke-document",
      [Cl.uint(1), Cl.uint(1)],
      address1
    );
    
    // Try to revoke again
    const { result } = simnet.callPublicFn(
      "Digital-Land-Registry",
      "revoke-document",
      [Cl.uint(1), Cl.uint(1)],
      address1
    );
    
    expect(result).toBeErr(Cl.uint(405)); // ERR_ALREADY_REVOKED
  });

  it("correctly tracks document count", () => {
    registerTestProperty(address1);
    
    // Initially should be 0
    let countResult = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-doc-count",
      [Cl.uint(1)],
      address1
    );
    expect(countResult.result).toBeUint(0);
    
    // Add first document
    const docHash1 = createDocHash("count-test-doc-1");
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1),
        Cl.buffer(docHash1),
        Cl.stringAscii("deed"),
        Cl.stringAscii("https://example.com/doc1.pdf")
      ],
      address1
    );
    
    // Should be 1
    countResult = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-doc-count",
      [Cl.uint(1)],
      address1
    );
    expect(countResult.result).toBeUint(1);
    
    // Add second document
    const docHash2 = createDocHash("count-test-doc-2");
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1),
        Cl.buffer(docHash2),
        Cl.stringAscii("survey"),
        Cl.stringAscii("https://example.com/doc2.pdf")
      ],
      address1
    );
    
    // Should be 2
    countResult = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-doc-count",
      [Cl.uint(1)],
      address1
    );
    expect(countResult.result).toBeUint(2);
  });

  it("correctly checks if document hash exists", () => {
    registerTestProperty(address1);
    const docHash = createDocHash("hash-exists-test");
    
    // Initially should not exist
    let hasResult = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "has-document",
      [Cl.uint(1), Cl.buffer(docHash)],
      address1
    );
    expect(hasResult.result).toBeBool(false);
    
    // Add document
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1),
        Cl.buffer(docHash),
        Cl.stringAscii("deed"),
        Cl.stringAscii("https://example.com/exists.pdf")
      ],
      address1
    );
    
    // Now should exist
    hasResult = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "has-document",
      [Cl.uint(1), Cl.buffer(docHash)],
      address1
    );
    expect(hasResult.result).toBeBool(true);
  });

  it("can get document ID by hash", () => {
    registerTestProperty(address1);
    const docHash = createDocHash("get-by-hash-test");
    
    // Add document
    simnet.callPublicFn(
      "Digital-Land-Registry",
      "add-document",
      [
        Cl.uint(1),
        Cl.buffer(docHash),
        Cl.stringAscii("deed"),
        Cl.stringAscii("https://example.com/by-hash.pdf")
      ],
      address1
    );
    
    // Get doc-id by hash
    const { result } = simnet.callReadOnlyFn(
      "Digital-Land-Registry",
      "get-doc-id-by-hash",
      [Cl.uint(1), Cl.buffer(docHash)],
      address1
    );
    
    expect(result).toBeDefined();
  });
});
