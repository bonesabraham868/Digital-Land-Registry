Property Document Registry

Overview
Allows property owners to attach verifiable document hashes and metadata to property records. Enhances due diligence and provenance tracking without external dependencies. Property owners can add documents like deeds, surveys, certificates, and permits to their properties, creating an immutable audit trail.

Technical Implementation
- Error constants: ERR_DOC_NOT_PROPERTY_OWNER (u401), ERR_DOC_PROPERTY_NOT_FOUND (u402), ERR_DOC_EXISTS (u403), ERR_DOC_NOT_FOUND (u404), ERR_ALREADY_REVOKED (u405)
- Storage maps: property-doc-counts, property-documents, property-doc-hash-index
- Public functions: add-document(property-id, doc-hash, doc-type, uri), revoke-document(property-id, doc-id)
- Read-only functions: get-document, get-doc-count, has-document, get-doc-id-by-hash
- Independent feature with no cross-contract calls or traits
- Clarity v3 compliant with proper data validation and error handling

Testing & Validation
✅ Contract passes clarinet check
✅ All npm tests successful (13 new tests added)  
✅ GitHub Actions CI workflow configured
✅ Proper ownership validation and duplicate prevention
✅ Comprehensive error handling and edge case coverage
✅ Line endings normalized to LF
