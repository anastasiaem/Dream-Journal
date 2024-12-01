# Dream Journal and Interpretation Platform

## Overview

A decentralized platform built on the Stacks blockchain that allows users to record, share, and interpret dreams while maintaining privacy and enabling community-driven analysis.

## Key Features

- Secure Dream Journaling
- NFT-based Dream Entries
- AI-Powered Dream Analysis
- Community Dream Interpretation
- Reputation System
- Privacy Controls

## Contract Components

### Data Structures
- **Dreams**: Stored with unique ID, content, timestamp, AI analysis
- **Interpreters**: Track interpreter profiles and reputation
- **Interpretations**: Link dreams with community interpretations
- **NFT**: Unique token for each dream entry

## Main Functions

### Dream Management
- `record-dream(content, is-public)`: Record a new dream
- `update-ai-analysis(dream-id, analysis)`: Add AI-generated insights
- `get-dream(dream-id)`: Retrieve dream details

### Interpretation System
- `register-interpreter()`: Become a dream interpreter
- `interpret-dream(dream-id, interpretation)`: Provide dream interpretation
- `rate-interpretation(dream-id, interpreter, rating)`: Rate interpretation quality

### Reputation Tracking
- Built-in reputation system for interpreters
- Ratings influence interpreter's credibility

## Usage Example

```clarity
;; Record a dream
(record-dream "I flew over mountains" true)

;; Register as an interpreter
(register-interpreter)

;; Interpret a public dream
(interpret-dream u1 "Flying symbolizes freedom")

;; Rate the interpretation
(rate-interpretation u1 interpreter-address u5)
```

## Security Features
- Owner-only AI analysis updates
- Public/private dream visibility
- Interpreter registration verification
- Rating-based reputation mechanism

## Error Handling
- Custom error codes for:
    - Owner-only actions
    - Resource not found
    - Unauthorized access
    - Duplicate registrations

## Reputation Calculation
- Initial reputation: 100
- Calculated using weighted average of ratings
- Encourages high-quality interpretations

## Test Coverage
Comprehensive test suite included:
- Dream recording
- AI analysis updates
- Interpreter registration
- Dream interpretation
- Interpretation rating

## Technology Stack
- Stacks Blockchain
- Clarity Smart Contract
- Vitest for testing

## Future Enhancements
- Advanced AI dream analysis
- Multi-language support
- More detailed reputation metrics
- Social sharing features

## Contributing
1. Fork the repository
2. Create feature branch
3. Commit changes
4. Submit pull request

## License
[Specify Open Source License]

## Contact
[Maintainer Contact Information]

