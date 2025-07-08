# Dynamic Categories System Guide

## Overview

The Gig app now uses a **dynamic category system** that automatically extracts categories from the sample data instead of using hardcoded values. This makes the system scalable and ensures that the AI recommendations always match the available providers.

## How It Works

### 1. Dynamic Category Extraction

The system automatically extracts categories from the `Provider.sampleData`:

```swift
static var availableCategories: [String] {
    let categories = Set(sampleData.map { $0.category })
    return Array(categories).sorted()
}
```

### 2. AI System Integration

The AI system now uses dynamic categories in both:
- **Real AI responses** (when API key is configured)
- **Mock responses** (fallback when API is unavailable)

### 3. Automatic Updates

When you add new providers with new categories, the AI system automatically:
- Recognizes the new categories
- Includes them in recommendations
- Updates the system prompt dynamically

## Current Available Categories

Based on the current sample data, these categories are available:

- **Carpenter** - Custom woodworking, furniture, construction
- **Cleaner** - House cleaning, deep cleaning, organizing
- **Coach** - Personal training, life coaching, fitness
- **Creative** - Photography, videography, graphic design
- **Electrician** - Electrical work, installations, repairs
- **Handyman** - General home repairs and maintenance
- **Landscaper** - Gardening, lawn care, outdoor design
- **Painter** - Interior/exterior painting, refinishing
- **Personal Trainer** - Fitness training, nutrition, weight loss
- **Photographer** - Portraits, events, commercial photography
- **Plumber** - Plumbing repairs, installations, maintenance
- **Tutor** - Academic subjects, test prep, skills training

## Utility Functions

### Category Validation
```swift
// Check if a category exists
Provider.isValidCategory("Handyman") // Returns true/false
```

### Provider Retrieval
```swift
// Get all providers for a category
let handymanProviders = Provider.providers(for: "Handyman")
```

### Category Statistics
```swift
// Get category statistics
let stats = Provider.categoryStats
// Returns: [(category: "Handyman", count: 2), ...]

// Print statistics for debugging
Provider.printCategoryStats()
```

### AI Prompt Generation
```swift
// Get formatted categories for AI prompts
let promptCategories = Provider.categoriesForAIPrompt
// Returns: "- Carpenter\n- Cleaner\n- Coach\n..."

// Get comma-separated list
let categoryList = Provider.categoriesList
// Returns: "Carpenter, Cleaner, Coach, ..."
```

## Adding New Categories

### Method 1: Add New Provider
Simply add a new provider with a new category to `Provider.sampleData`:

```swift
Provider(
    name: "John Doe",
    category: "NewCategory", // This automatically becomes available
    // ... other properties
)
```

### Method 2: Update Existing Provider
Change an existing provider's category:

```swift
Provider(
    name: "Existing Provider",
    category: "UpdatedCategory", // Updates the available categories
    // ... other properties
)
```

## Benefits

### 1. **Scalability**
- No need to manually update hardcoded category lists
- New categories are automatically recognized
- System grows with your data

### 2. **Consistency**
- AI recommendations always match available providers
- No more "ghost categories" that don't exist
- Real-time category validation

### 3. **Maintainability**
- Single source of truth for categories
- Easy to add/remove categories
- Automatic synchronization

### 4. **Debugging**
- Comprehensive logging of category usage
- Statistics tracking
- Validation helpers

## Debugging

### Console Output
The system provides detailed logging:

```
[ChatService] Available categories: Carpenter, Cleaner, Coach, Creative, Electrician, Handyman, Landscaper, Painter, Personal Trainer, Photographer, Plumber, Tutor
📊 Category Statistics:
   Carpenter: 1 providers
   Cleaner: 2 providers
   Coach: 1 providers
   ...
   Total categories: 12
   Total providers: 15
```

### Category Validation
```swift
// Check if AI recommendation is valid
if Provider.isValidCategory(recommendation.service) {
    // Category exists, proceed
} else {
    // Category doesn't exist, handle gracefully
}
```

## Future Enhancements

### 1. **User-Generated Categories**
When users can create their own categories:
- Categories will be stored in a database
- Dynamic extraction will include user categories
- AI system will automatically adapt

### 2. **Category Hierarchies**
- Parent/child category relationships
- Subcategories for better organization
- Intelligent category matching

### 3. **Category Analytics**
- Track which categories are most popular
- Monitor AI recommendation accuracy
- Identify gaps in service coverage

## Best Practices

### 1. **Category Naming**
- Use consistent, clear category names
- Avoid special characters or spaces
- Keep names concise but descriptive

### 2. **Data Consistency**
- Ensure all providers have valid categories
- Use the same category name across providers
- Validate categories before saving

### 3. **Testing**
- Test with new categories regularly
- Verify AI recommendations match available providers
- Monitor category statistics

---

**Note**: This system ensures that your AI recommendations are always based on real, available providers, making the user experience more reliable and accurate. 