# Tona Backend Implementation Guide

## Project Overview

Tona is a mobile photo processing application that uses AI to process and enhance images. This document outlines the backend implementation using **Supabase only** as the backend platform.

## Technology Stack

### Backend Platform
- **Supabase** - Complete backend-as-a-service platform
- **PostgreSQL** - Supabase's built-in database
- **Supabase Storage** - File storage for uploaded images and processed results
- **Supabase Edge Functions** - Serverless functions for AI processing
- **Supabase Realtime** - Real-time status updates

### Database
- **Supabase PostgreSQL** - Primary database for job tracking and metadata
- **Row Level Security (RLS)** - Built-in security policies

### File Storage
- **Supabase Storage** - Primary file storage for uploaded images and processed results
- **CDN** - Supabase's built-in CDN for fast image delivery

### Image Processing
- **Supabase Edge Functions** - Serverless AI processing
- **Queue System** - Built-in job queuing with Edge Functions
- **Background Processing** - Asynchronous image processing

## API Structure

### Base Configuration
- **Base URL:** https://your-project.supabase.co
- **Content-Type:** application/json (except file uploads)
- **File Upload:** multipart/form-data via Supabase Storage

### Endpoints Implementation

#### 1. Upload First Group
- **Method:** POST
- **Endpoint:** /upload-first-group
- **Implementation:** Supabase Storage API
- **Request:** Form data with files[] field containing image files
- **File Types:** JPEG, PNG, WebP
- **Max File Size:** 10MB per file
- **Max Files:** 10 files per request
- **Response:** Success message, group ID, uploaded file details

#### 2. Upload Second Group
- **Method:** POST
- **Endpoint:** /upload-second-group
- **Implementation:** Supabase Storage API
- **Request/Response:** Same structure as first group upload

#### 3. Start Processing
- **Method:** POST
- **Endpoint:** /start-processing
- **Implementation:** Supabase Edge Function
- **Content-Type:** application/json
- **Request Body:**
  - userId: string
  - jobName: string
  - firstGroupId: string
  - secondGroupId: string
  - notifyUrl: string
  - options: object (style, faceEnhancement, targetResolution)
- **Response:** Job ID, success message

#### 4. Check Status
- **Method:** GET
- **Endpoint:** /status/{jobId}
- **Implementation:** Supabase Database query
- **Response:**
  - jobId: string
  - status: string (editing, processing, completed, etc.)
  - progress: number (0-100)
  - currentStep: string
  - finished: boolean
  - errors: array

#### 5. Get Result
- **Method:** GET
- **Endpoint:** /result/{jobId}
- **Implementation:** Supabase Storage + Database
- **Response:**
  - jobId: string
  - finished: boolean
  - resultUrls: array of Supabase Storage URLs

#### 6. Cancel Job
- **Method:** DELETE
- **Endpoint:** /cancel/{jobId}
- **Implementation:** Supabase Database update
- **Response:** Success message, job ID

## Supabase Database Schema

### Jobs Table
- **id:** UUID primary key
- **user_id:** string
- **job_name:** string
- **status:** string (queued, processing, editing, completed, failed, cancelled)
- **progress:** integer (0-100)
- **first_group_id:** string
- **second_group_id:** string
- **options:** JSONB (processing options)
- **result_urls:** array of strings
- **created_at:** timestamp
- **started_at:** timestamp
- **completed_at:** timestamp
- **processing_time:** integer (seconds)

### File Groups Table
- **id:** string primary key
- **user_id:** string
- **files:** array of file objects
- **created_at:** timestamp
- **expires_at:** timestamp

### Results Table
- **id:** UUID primary key
- **job_id:** UUID foreign key
- **file_path:** string
- **file_size:** integer
- **created_at:** timestamp

## Supabase Implementation Architecture

### 1. File Upload Service
- **Supabase Storage** for file handling
- **Supabase Client** for multipart form data
- File type and size validation
- Generate unique file IDs
- Return file metadata

### 2. Processing Service
- **Supabase Edge Functions** for job creation
- **Supabase Database** for job tracking
- **Supabase Realtime** for status updates
- Handle processing errors
- Update job completion status

### 3. AI Processing Worker
- **Supabase Edge Functions** for AI processing
- Load AI models in serverless environment
- Process images based on options
- Generate result images
- Upload results to Supabase Storage
- Update job status via database

### 4. Status Tracking Service
- **Supabase Realtime** for real-time updates
- **Supabase Database** for progress tracking
- Error handling and reporting
- Webhook notifications via Edge Functions

### 5. Result Delivery Service
- **Supabase Storage** for result URLs
- **Supabase CDN** for fast delivery
- Handle file downloads
- Manage file expiration
- Provide download statistics

## Processing Options

### Supported Options
- **style:** realistic, artistic, vintage, modern
- **faceEnhancement:** boolean
- **targetResolution:** 1024x1024, 1920x1920, 4096x4096
- **quality:** low, medium, high, ultra
- **format:** jpeg, png, webp

### Processing Pipeline
1. **Validation** - Check input files and options
2. **Preprocessing** - Resize, format, optimize images
3. **AI Processing** - Apply AI models via Edge Functions
4. **Postprocessing** - Final adjustments and optimization
5. **Output** - Generate result images and metadata

## Error Handling

### Standard Error Response
- **error.code:** Error type identifier
- **error.message:** Human-readable error message
- **error.details:** Additional error context
- **error.timestamp:** When error occurred
- **error.requestId:** Unique request identifier

### Common Error Codes
- **VALIDATION_ERROR** - Request validation failed
- **FILE_TOO_LARGE** - Uploaded file exceeds size limit
- **INVALID_FILE_FORMAT** - Unsupported file type
- **JOB_NOT_FOUND** - Job ID doesn't exist
- **JOB_ALREADY_COMPLETED** - Cannot modify completed job
- **PROCESSING_ERROR** - AI processing failed
- **STORAGE_ERROR** - Supabase Storage issue

## Security Implementation

### Supabase Security Features
- **Row Level Security (RLS)** - Database-level security
- **Supabase Auth** - Built-in authentication (if needed later)
- **API Keys** - Secure API access
- **Storage Policies** - File access control

### File Upload Security
- File type validation (magic number checking)
- File size limits (10MB per file, 100MB total per request)
- Supabase Storage security policies
- Signed URLs for secure file access

### API Security
- Input validation and sanitization
- SQL injection prevention via Supabase
- XSS protection
- Rate limiting via Supabase
- CORS configuration

## Performance Optimization

### Supabase Optimization
- **Database Indexing** - Optimized queries with proper indexes
- **Storage CDN** - Built-in CDN for fast file delivery
- **Edge Functions** - Serverless processing for scalability
- **Realtime** - Efficient real-time updates

### Caching Strategy
- **Supabase Database** - Built-in query optimization
- **Storage CDN** - Automatic caching for static assets
- **Edge Functions** - Serverless caching

## Deployment Architecture

### Development Environment
- **Supabase Local** - Local development setup
- **Supabase CLI** - Development tools
- **Local Storage** - Development file storage

### Production Environment
- **Supabase Cloud** - Managed production environment
- **Supabase Dashboard** - Monitoring and management
- **Supabase Analytics** - Usage tracking
- **Supabase Logs** - Application logging

## Implementation Phases

### Phase 1: Foundation
- Supabase project setup
- Database schema creation
- Basic file upload via Supabase Storage
- Error handling framework

### Phase 2: Processing Pipeline
- Edge Functions for job processing
- AI processing worker implementation
- Status tracking via Realtime
- Result delivery service

### Phase 3: Optimization
- Performance improvements
- Caching implementation
- Monitoring and logging
- Security enhancements

### Phase 4: Deployment
- Production Supabase setup
- CI/CD pipeline
- Load testing
- Documentation

This implementation guide provides a comprehensive roadmap for building the Tona backend system using **Supabase only** as the complete backend platform.