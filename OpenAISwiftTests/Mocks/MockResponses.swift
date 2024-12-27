struct MockResponses {
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
    
    static let embeddings = """
    {
        "object": "list",
        "data": [{
            "object": "embedding",
            "embedding": [0.0023064255, -0.009327292, 0.015797347, -0.0077780345],
            "index": 0
        }],
        "model": "text-embedding-ada-002",
        "usage": {
            "prompt_tokens": 8,
            "total_tokens": 8
        }
    }
    """
    
    static let embeddingsMultiple = """
    {
        "object": "list",
        "data": [
            {
                "object": "embedding",
                "embedding": [0.0023064255, -0.009327292, 0.015797347, -0.0077780345],
                "index": 0
            },
            {
                "object": "embedding",
                "embedding": [0.0028064255, -0.008327292, 0.016797347, -0.0067780345],
                "index": 1
            }
        ],
        "model": "text-embedding-ada-002",
        "usage": {
            "prompt_tokens": 16,
            "total_tokens": 16
        }
    }
    """
}
