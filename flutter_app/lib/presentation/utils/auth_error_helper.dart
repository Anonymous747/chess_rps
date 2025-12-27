import 'package:dio/dio.dart';

/// Helper class to convert authentication errors into user-friendly messages
class AuthErrorHelper {
  /// Convert an exception to a user-friendly error message
  static String getUserFriendlyError(dynamic error) {
    if (error is DioException) {
      return _handleDioException(error);
    }
    
    final errorString = error.toString();
    
    // Handle specific API error messages
    if (errorString.toLowerCase().contains('phone') && 
        errorString.toLowerCase().contains('already exists')) {
      return 'This phone number is already registered. Please try logging in instead.';
    }
    
    if (errorString.toLowerCase().contains('phone') && 
        errorString.toLowerCase().contains('not found')) {
      return 'Phone number not found. Please check your number or sign up for a new account.';
    }
    
    if (errorString.toLowerCase().contains('invalid') && 
        errorString.toLowerCase().contains('password')) {
      return 'Incorrect password. Please try again or reset your password.';
    }
    
    if (errorString.toLowerCase().contains('incorrect') && 
        errorString.toLowerCase().contains('password')) {
      return 'Incorrect password. Please try again.';
    }
    
    if (errorString.toLowerCase().contains('invalid') && 
        errorString.toLowerCase().contains('credentials')) {
      return 'Invalid phone number or password. Please check your credentials and try again.';
    }
    
    if (errorString.toLowerCase().contains('weak') && 
        errorString.toLowerCase().contains('password')) {
      return 'Password is too weak. Please use at least 8 characters.';
    }
    
    if (errorString.toLowerCase().contains('invalid') && 
        errorString.toLowerCase().contains('phone')) {
      return 'Invalid phone number format. Please enter a valid phone number.';
    }
    
    if (errorString.toLowerCase().contains('network') || 
        errorString.toLowerCase().contains('connection')) {
      return 'Network connection error. Please check your internet connection and try again.';
    }
    
    if (errorString.toLowerCase().contains('timeout')) {
      return 'Request timed out. Please check your internet connection and try again.';
    }
    
    if (errorString.toLowerCase().contains('server')) {
      return 'Server error. Please try again later.';
    }
    
    // Remove "Exception: " prefix if present
    String message = errorString.replaceAll('Exception: ', '');
    message = message.replaceAll('Exception', '');
    message = message.trim();
    
    // If the message is empty or just the class name, provide a generic message
    if (message.isEmpty || message == error.runtimeType.toString()) {
      return 'An unexpected error occurred. Please try again.';
    }
    
    // Capitalize first letter
    if (message.isNotEmpty) {
      message = message[0].toUpperCase() + message.substring(1);
    }
    
    return message;
  }
  
  /// Handle DioException specifically
  static String _handleDioException(DioException error) {
    // Check for specific HTTP status codes
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final errorData = error.response!.data;
      
      // Try to extract a detail message from the response
      String? detailMessage;
      if (errorData is Map<String, dynamic>) {
        detailMessage = errorData['detail']?.toString();
        if (detailMessage == null || detailMessage.isEmpty) {
          detailMessage = errorData['message']?.toString();
        }
      }
      
      // Handle specific status codes
      switch (statusCode) {
        case 400:
          if (detailMessage != null) {
            return _processDetailMessage(detailMessage);
          }
          return 'Invalid request. Please check your information and try again.';
          
        case 401:
          return 'Invalid phone number or password. Please check your credentials and try again.';
          
        case 403:
          return 'Access denied. Please check your credentials.';
          
        case 404:
          if (detailMessage != null && detailMessage.toLowerCase().contains('user')) {
            return 'Account not found. Please sign up for a new account.';
          }
          return 'Resource not found. Please try again.';
          
        case 409:
          if (detailMessage != null && detailMessage.toLowerCase().contains('phone')) {
            return 'This phone number is already registered. Please try logging in instead.';
          }
          return 'Account already exists. Please try logging in instead.';
          
        case 422:
          if (detailMessage != null) {
            return _processDetailMessage(detailMessage);
          }
          return 'Invalid information provided. Please check your input and try again.';
          
        case 429:
          return 'Too many requests. Please wait a moment and try again.';
          
        case 500:
        case 502:
        case 503:
        case 504:
          return 'Server error. Please try again later.';
          
        default:
          if (detailMessage != null) {
            return _processDetailMessage(detailMessage);
          }
          return 'An error occurred. Please try again.';
      }
    }
    
    // Handle connection errors
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Connection timeout. Please check your internet connection and try again.';
        
      case DioExceptionType.connectionError:
        return 'Unable to connect to the server. Please check your internet connection.';
        
      case DioExceptionType.badResponse:
        return 'Server returned an error. Please try again.';
        
      case DioExceptionType.cancel:
        return 'Request was cancelled. Please try again.';
        
      case DioExceptionType.unknown:
      default:
        final message = error.message ?? 'Unknown error';
        if (message.toLowerCase().contains('network') || 
            message.toLowerCase().contains('connection')) {
          return 'Network connection error. Please check your internet connection and try again.';
        }
        return 'An unexpected error occurred. Please try again.';
    }
  }
  
  /// Process detail messages from API to make them more user-friendly
  static String _processDetailMessage(String detailMessage) {
    final lowerMessage = detailMessage.toLowerCase();
    
    // Phone number related
    if (lowerMessage.contains('phone') && lowerMessage.contains('already')) {
      return 'This phone number is already registered. Please try logging in instead.';
    }
    
    if (lowerMessage.contains('phone') && lowerMessage.contains('not found')) {
      return 'Phone number not found. Please check your number or sign up for a new account.';
    }
    
    if (lowerMessage.contains('phone') && lowerMessage.contains('invalid')) {
      return 'Invalid phone number format. Please enter a valid phone number.';
    }
    
    // Password related
    if (lowerMessage.contains('password') && lowerMessage.contains('incorrect')) {
      return 'Incorrect password. Please try again.';
    }
    
    if (lowerMessage.contains('password') && lowerMessage.contains('invalid')) {
      return 'Invalid password. Please check your password and try again.';
    }
    
    if (lowerMessage.contains('password') && lowerMessage.contains('weak')) {
      return 'Password is too weak. Please use at least 8 characters with a mix of letters and numbers.';
    }
    
    if (lowerMessage.contains('password') && lowerMessage.contains('short')) {
      return 'Password is too short. Please use at least 8 characters.';
    }
    
    // Credentials related
    if (lowerMessage.contains('invalid') && lowerMessage.contains('credentials')) {
      return 'Invalid phone number or password. Please check your credentials and try again.';
    }
    
    if (lowerMessage.contains('authentication failed')) {
      return 'Authentication failed. Please check your phone number and password.';
    }
    
    // User related
    if (lowerMessage.contains('user') && lowerMessage.contains('not found')) {
      return 'Account not found. Please sign up for a new account.';
    }
    
    if (lowerMessage.contains('user') && lowerMessage.contains('already exists')) {
      return 'Account already exists. Please try logging in instead.';
    }
    
    // Validation errors
    if (lowerMessage.contains('validation') || lowerMessage.contains('invalid')) {
      return 'Invalid information provided. Please check your input and try again.';
    }
    
    // Return the original message if no specific pattern matches, but capitalize first letter
    if (detailMessage.isNotEmpty) {
      return detailMessage[0].toUpperCase() + detailMessage.substring(1);
    }
    
    return detailMessage;
  }
}

