import 'package:flutter/material.dart';
import '../models/comment_model.dart';
import '../services/comment_api_service.dart';

enum CommentState { initial, loading, loaded, error }

class CommentProvider with ChangeNotifier {
  CommentState _state = CommentState.initial;
  List<Comment> _comments = [];
  String? _errorMessage;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  // Getters
  CommentState get state => _state;
  List<Comment> get comments => _comments;
  String? get errorMessage => _errorMessage;
  bool get isCreating => _isCreating;
  bool get isUpdating => _isUpdating;
  bool get isDeleting => _isDeleting;
  bool get isLoading => _state == CommentState.loading;

  void _setState(CommentState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _setState(CommentState.error);
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _state = CommentState.initial;
    _comments = [];
    _errorMessage = null;
    _isCreating = false;
    _isUpdating = false;
    _isDeleting = false;
    notifyListeners();
  }

  // Fetch comments for an entity
  Future<void> fetchComments({
    required String token,
    required String entityType,
    required String entityId,
    int page = 1,
    int limit = 20,
    String sort = 'asc',
  }) async {
    _setState(CommentState.loading);
    _errorMessage = null;

    try {
      final response = await CommentApiService.getComments(
        token: token,
        entityType: entityType,
        entityId: entityId,
        page: page,
        limit: limit,
        sort: sort,
      );

      if (response.isSuccess) {
        _comments = response.model ?? [];
        _setState(CommentState.loaded);
      } else {
        // Only show error if it's not just "no comments"
        if (response.statusCode != 200) {
          _setError(response.message);
        } else {
          _comments = [];
          _setState(CommentState.loaded);
        }
      }
    } catch (e) {
      print('Error fetching comments: $e');
      // For empty comments, don't show error - just show empty state
      if (e.toString().contains('comments') && e.toString().contains('null')) {
        _comments = [];
        _setState(CommentState.loaded);
      } else {
        _setError('Failed to fetch comments: $e');
      }
    }
  }

  // Create a new comment
  Future<bool> createComment({
    required String token,
    required String entityType,
    required String entityId,
    required String content,
    String? parentId,
    List<String>? attachments,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await CommentApiService.createComment(
        token: token,
        entityType: entityType,
        entityId: entityId,
        content: content,
        parentId: parentId,
        attachments: attachments,
      );

      if (response.isSuccess && response.model != null) {
        final newComment = response.model!;

        if (parentId != null) {
          // If it's a reply, add to parent comment's replies
          _addReplyToParent(parentId, newComment);
        } else {
          // If it's a top-level comment, add to main comments list
          _comments.insert(0, newComment);
        }

        _isCreating = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isCreating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to create comment: $e';
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  // Update a comment
  Future<bool> updateComment({
    required String token,
    required String commentId,
    required String content,
    List<String>? attachments,
  }) async {
    _isUpdating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await CommentApiService.updateComment(
        token: token,
        commentId: commentId,
        content: content,
      );

      if (response.isSuccess && response.model != null) {
        final updatedComment = response.model!;
        _updateCommentInList(commentId, updatedComment);

        _isUpdating = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isUpdating = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to update comment: $e';
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  // Delete a comment
  Future<bool> deleteComment({
    required String token,
    required String commentId,
  }) async {
    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await CommentApiService.deleteComment(
        token: token,
        commentId: commentId,
      );

      if (response.isSuccess) {
        _removeCommentFromList(commentId);

        _isDeleting = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        _isDeleting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Failed to delete comment: $e';
      _isDeleting = false;
      notifyListeners();
      return false;
    }
  }

  // Helper method to add reply to parent comment
  void _addReplyToParent(String parentId, Comment reply) {
    for (int i = 0; i < _comments.length; i++) {
      if (_comments[i].id == parentId) {
        final parentComment = _comments[i];

        _comments[i] = Comment(
          id: parentComment.id,
          entityType: parentComment.entityType,
          entityId: parentComment.entityId,
          author: parentComment.author,
          content: parentComment.content,
          createdAt: parentComment.createdAt,
          updatedAt: parentComment.updatedAt,
          parentId: parentComment.parentId,
          attachments: parentComment.attachments,
          isDeleted: parentComment.isDeleted,
        );
        break;
      }
    }
  }

  // Helper method to update comment in list
  void _updateCommentInList(String commentId, Comment updatedComment) {
    for (int i = 0; i < _comments.length; i++) {
      if (_comments[i].id == commentId) {
        _comments[i] = updatedComment;
        break;
      }
    }
  }

  // Helper method to remove comment from list
  void _removeCommentFromList(String commentId) {
    _comments.removeWhere((comment) => comment.id == commentId);
  }
}
