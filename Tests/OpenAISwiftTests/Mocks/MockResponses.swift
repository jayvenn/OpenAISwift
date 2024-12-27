import Foundation

/// Mock API responses for testing
enum MockResponses {
    static let chatCompletion = """
    {
        "id": "chatcmpl-123",
        "object": "chat.completion",
        "created": 1677652288,
        "model": "gpt-3.5-turbo",
        "choices": [{
            "index": 0,
            "message": {
                "role": "assistant",
                "content": "Hello! How can I help you today?"
            },
            "finish_reason": "stop"
        }],
        "usage": {
            "prompt_tokens": 9,
            "completion_tokens": 12,
            "total_tokens": 21
        }
    }
    """
    
    static let embedding = """
    {
        "object": "list",
        "data": [{
            "object": "embedding",
            "embedding": [0.0023064255, -0.009327292, 0.015954123],
            "index": 0
        }],
        "model": "text-embedding-ada-002",
        "usage": {
            "prompt_tokens": 8,
            "total_tokens": 8
        }
    }
    """
    
    static let error = """
    {
        "error": {
            "message": "Invalid API key",
            "type": "invalid_request_error",
            "code": "invalid_api_key"
        }
    }
    """
}
