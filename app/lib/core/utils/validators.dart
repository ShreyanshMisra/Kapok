class Validators {
  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    
    return null;
  }

  /// Validates password strength
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    
    return null;
  }

  /// Validates password confirmation
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    
    if (value != password) {
      return 'Passwords do not match';
    }
    
    return null;
  }

  /// Validates name field
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters long';
    }
    
    if (value.length > 50) {
      return 'Name must be less than 50 characters';
    }
    
    // Check for valid characters (letters, spaces, hyphens, apostrophes)
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(value)) {
      return 'Name can only contain letters, spaces, hyphens, and apostrophes';
    }
    
    return null;
  }

  /// Validates team code format
  static String? teamCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Team code is required';
    }
    
    if (value.length < 4) {
      return 'Team code must be at least 4 characters long';
    }
    
    if (value.length > 20) {
      return 'Team code must be less than 20 characters';
    }
    
    // Check for alphanumeric characters only
    final codeRegex = RegExp(r'^[a-zA-Z0-9]+$');
    if (!codeRegex.hasMatch(value)) {
      return 'Team code can only contain letters and numbers';
    }
    
    return null;
  }

  /// Validates task name
  static String? taskName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Task name is required';
    }
    
    if (value.length < 3) {
      return 'Task name must be at least 3 characters long';
    }
    
    if (value.length > 100) {
      return 'Task name must be less than 100 characters';
    }
    
    return null;
  }

  /// Validates task description
  static String? taskDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Task description is required';
    }
    
    if (value.length < 10) {
      return 'Task description must be at least 10 characters long';
    }
    
    if (value.length > 500) {
      return 'Task description must be less than 500 characters';
    }
    
    return null;
  }

  /// Validates task severity (1-5)
  static String? taskSeverity(int? value) {
    if (value == null) {
      return 'Task severity is required';
    }
    
    if (value < 1 || value > 5) {
      return 'Task severity must be between 1 and 5';
    }
    
    return null;
  }

  /// Validates team name
  static String? teamName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Team name is required';
    }
    
    if (value.length < 3) {
      return 'Team name must be at least 3 characters long';
    }
    
    if (value.length > 50) {
      return 'Team name must be less than 50 characters';
    }
    
    return null;
  }

  /// Validates latitude
  static String? latitude(double? value) {
    if (value == null) {
      return 'Latitude is required';
    }
    
    if (value < -90 || value > 90) {
      return 'Latitude must be between -90 and 90';
    }
    
    return null;
  }

  /// Validates longitude
  static String? longitude(double? value) {
    if (value == null) {
      return 'Longitude is required';
    }
    
    if (value < -180 || value > 180) {
      return 'Longitude must be between -180 and 180';
    }
    
    return null;
  }

  /// Validates required field
  static String? required(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    return null;
  }

  /// Validates minimum length
  static String? minLength(String? value, int minLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters long';
    }
    
    return null;
  }

  /// Validates maximum length
  static String? maxLength(String? value, int maxLength, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    
    if (value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }
    
    return null;
  }

  /// Validates numeric range
  static String? numericRange(num? value, num min, num max, String fieldName) {
    if (value == null) {
      return '$fieldName is required';
    }
    
    if (value < min || value > max) {
      return '$fieldName must be between $min and $max';
    }
    
    return null;
  }

  /// Validates phone number (basic format)
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove all non-digit characters
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must be at least 10 digits';
    }
    
    if (digitsOnly.length > 15) {
      return 'Phone number must be less than 15 digits';
    }
    
    return null;
  }

  /// Validates URL format
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return 'URL is required';
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Please enter a valid URL';
    }
    
    return null;
  }

  /// Combines multiple validators
  static String? combine(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}

