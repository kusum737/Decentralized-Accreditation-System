// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedAccreditation {
    
    struct Credential {
        address issuer;
        address recipient;
        string credentialHash;
        uint256 issueDate;
        bool isValid;
    }

    mapping(bytes32 => Credential) public credentials;
    event CredentialIssued(address indexed issuer, address indexed recipient, bytes32 credentialId, uint256 issueDate);
    event CredentialRevoked(address indexed issuer, bytes32 credentialId);

    modifier onlyIssuer(bytes32 credentialId) {
        require(credentials[credentialId].issuer == msg.sender, "Only the issuer can perform this action");
        _;
    }

    function issueCredential(address _recipient, string memory _credentialHash) public returns (bytes32) {
        bytes32 credentialId = keccak256(abi.encodePacked(msg.sender, _recipient, _credentialHash, block.timestamp));

        credentials[credentialId] = Credential({
            issuer: msg.sender,
            recipient: _recipient,
            credentialHash: _credentialHash,
            issueDate: block.timestamp,
            isValid: true
        });

        emit CredentialIssued(msg.sender, _recipient, credentialId, block.timestamp);
        return credentialId;
    }

    function revokeCredential(bytes32 credentialId) public onlyIssuer(credentialId) {
        credentials[credentialId].isValid = false;
        emit CredentialRevoked(msg.sender, credentialId);
    }

    function verifyCredential(bytes32 credentialId) public view returns (bool) {
        return credentials[credentialId].isValid;
    }

}
