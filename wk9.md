# Functional Dependency (FD)

**X → Y**

- Y functionally depends on X
- X determines Y
- If we know X then we know Y

**Rules**

- Reflexivity: X → X
- Augmentation: X → Y implies XZ → YZ
- Transitivity: X → Y, Y → Z implies X → Z
- Additivity: X → Y, X → Z implies X → YZ
- Projectivity: X → YZ implies X → Y, X → Z
- Pseudotransitivity: X → Y, YZ → W implies XZ → W

**Trivial Functional Dependency**

- If Y is a subset of X, then X → Y is a trivial functional dependency

# Closure

**Notation: X+**

- This is the largest set of attributes that can be derived from X using F, where
- X is the set of attributes
- F is the set of functional dependencies

**Example: R = {A, B, C, D}, F = {A → B, B → C, C → D}**

- A+ = {A, B, C, D}
- B+ = {B, C, D}
- C+ = {C, D}
- D+ = {D}

**Method, given an attribute and a set of functional dependencies**

- Take the attribute
- Use the FDs to figure out what dependencies are implied
- Keep doing this until we are unable to continue

## Super Key

- Set of attributes that uniquely identifies a tuple/row in a table
- Any set X, such that X+ = R

## Candidate Key

- Minimal superkey (pretty much a primary key)
- Any set X, such that X+ = R and there is no Y subset of X such that Y+ = R (cannot be further reduced)
- If X is a candidate key, then X is a super key (but not vice versa)

## Minimal Cover

- Smallest set of functional dependencies (FDs) that covers the entire set of FD
  - Put FDs into canonical form (convert into X → Y where Y is a single attribute)
  - Eliminate redundant attributes (look out if X's are multi-part)
  - Eliminate redundant FDs (look out for cycles, or FDs according to the rules above)

# Boyce-Codd Normal Form (BCNF)

_Eliminates all redundancy due to functional dependencies, but may not preserve original FDs_

**For all functional dependencies X → Y, EITHER**

- X → Y is trivial OR
- X is a super key

## BCNF Decomposition

1. Start with the original schema
2. Check all FDs that pertain to the current schema
   - i.e. the FD’s letters are a subset of the schema
   - e.g. A → B pertains to ABC, but B → D does not pertain to ABC, as D is not part of the schema
3. If all FDs are in BCNF, this schema is fine as is; skip to step 5
4. If any FD is not in BCNF, subtract the RHS from the schema, and add another schema that is the LHS + the RHS
   - e.g. for schema ABCD, if B → D is not in BCNF, then replace this schema with (itself - RHS), (LHS + RHS)
   - In this case, it becomes (ABCD - D), (B + D) = ABC, BD
5. Move on to the next schema in the set
6. Repeat from step 2 until there are no more changes to make

# Third Normal Form (3NF)

_Eliminates most (not all) redundancy due to functional dependencies, but guaranteed to preserve all FDs_

**For all functional dependencies X → Y, ONE OF**

- X → Y is trivial OR
- X is a super key OR
- Y is a single attribute of a candidate key

## 3NF Decomposition

1. "Flatten" all FDs in the reduced minimal cover
   - i.e. remove the arrows (convert into relations)
   - e.g. A → B, C → D, E → A becomes AB, CD, EA (with primary keys A, C, E respectively)
2. If the resulting set doesn't contain a candidate key, add one to the set (create a new relation with the corresponding primary key)
