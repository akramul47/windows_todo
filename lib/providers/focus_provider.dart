import 'dart:async';
import 'package:flutter/material.dart';
import '../models/timer_state.dart';
import '../services/storage_service.dart';

class FocusProvider extends ChangeNotifier {
  final StorageService _storageService = StorageService();
  
  TimerStatus _status = TimerStatus.idle;
  SessionType _currentSessionType = SessionType.focus;
  TimerSettings _settings = const TimerSettings();
  
  int _remainingSeconds = 25 * 60; // Default 25 minutes
  int _completedFocusSessions = 0;
  int _totalFocusTimeToday = 0; // in seconds
  DateTime? _sessionStartTime;
  
  Timer? _timer;
  List<FocusSession> _todaySessions = [];
  bool _showCelebration = false;

  // Getters
  TimerStatus get status => _status;
  SessionType get currentSessionType => _currentSessionType;
  TimerSettings get settings => _settings;
  int get remainingSeconds => _remainingSeconds;
  int get completedFocusSessions => _completedFocusSessions;
  int get totalFocusTimeToday => _totalFocusTimeToday;
  List<FocusSession> get todaySessions => _todaySessions;
  bool get showCelebration => _showCelebration;
  
  double get progress {
    final totalSeconds = _getCurrentSessionDuration() * 60;
    return totalSeconds > 0 ? (_remainingSeconds / totalSeconds) : 0;
  }

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get sessionTypeLabel {
    switch (_currentSessionType) {
      case SessionType.focus:
        return 'Focus Time';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  int _getCurrentSessionDuration() {
    switch (_currentSessionType) {
      case SessionType.focus:
        return _settings.focusDuration;
      case SessionType.shortBreak:
        return _settings.shortBreakDuration;
      case SessionType.longBreak:
        return _settings.longBreakDuration;
    }
  }

  void startTimer() {
    if (_status == TimerStatus.idle) {
      _sessionStartTime = DateTime.now();
    }
    
    _status = TimerStatus.running;
    _timer?.cancel();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _onTimerComplete();
      }
    });
    
    notifyListeners();
  }

  void pauseTimer() {
    _status = TimerStatus.paused;
    _timer?.cancel();
    notifyListeners();
  }

  void stopTimer() {
    _status = TimerStatus.idle;
    _timer?.cancel();
    _resetTimer();
    _sessionStartTime = null;
    notifyListeners();
  }

  void skipToBreak() {
    stopTimer();
    _startBreak();
  }

  void skipBreak() {
    stopTimer();
    _currentSessionType = SessionType.focus;
    _resetTimer();
  }

  void _onTimerComplete() {
    _timer?.cancel();
    _status = TimerStatus.completed;
    
    // Record session
    if (_currentSessionType == SessionType.focus) {
      _completedFocusSessions++;
      _totalFocusTimeToday += _settings.focusDuration * 60;
      
      _todaySessions.add(FocusSession(
        startTime: _sessionStartTime ?? DateTime.now(),
        endTime: DateTime.now(),
        durationMinutes: _settings.focusDuration,
        type: SessionType.focus,
        completed: true,
      ));
      
      // Save session data
      _saveFocusData();
      
      // Show celebration animation
      _showCelebration = true;
      notifyListeners();
      
      // Hide celebration after 3 seconds
      Future.delayed(const Duration(seconds: 3), () {
        _showCelebration = false;
        notifyListeners();
      });
    }
    
    notifyListeners();
    
    // Auto-start next session based on settings
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentSessionType == SessionType.focus) {
        if (_settings.autoStartBreaks) {
          _startBreak();
        }
      } else {
        if (_settings.autoStartFocus) {
          _currentSessionType = SessionType.focus;
          _resetTimer();
          startTimer();
        }
      }
    });
  }

  void _startBreak() {
    // Determine if it's time for a long break
    if (_completedFocusSessions > 0 && 
        _completedFocusSessions % _settings.sessionsUntilLongBreak == 0) {
      _currentSessionType = SessionType.longBreak;
    } else {
      _currentSessionType = SessionType.shortBreak;
    }
    
    _resetTimer();
    
    if (_settings.autoStartBreaks) {
      startTimer();
    }
  }

  void _resetTimer() {
    _remainingSeconds = _getCurrentSessionDuration() * 60;
  }

  void updateSettings(TimerSettings newSettings) {
    final wasRunning = _status == TimerStatus.running;
    if (wasRunning) {
      pauseTimer();
    }
    
    _settings = newSettings;
    _resetTimer();
    _saveSettings();
    
    if (wasRunning) {
      startTimer();
    } else {
      notifyListeners();
    }
  }

  void setFocusDuration(int minutes) {
    updateSettings(_settings.copyWith(focusDuration: minutes));
  }

  void resetDailyStats() {
    _completedFocusSessions = 0;
    _totalFocusTimeToday = 0;
    _todaySessions.clear();
    _saveFocusData();
    notifyListeners();
  }

  // Persistence methods
  Future<void> loadSettings() async {
    _settings = await _storageService.loadFocusSettings();
    _resetTimer();
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    await _storageService.saveFocusSettings(_settings);
  }

  Future<void> loadSessionData() async {
    final data = await _storageService.loadFocusSessionData();
    _completedFocusSessions = data['sessions'] ?? 0;
    _totalFocusTimeToday = data['totalTime'] ?? 0;
    notifyListeners();
  }

  Future<void> _saveFocusData() async {
    await _storageService.saveFocusSessionData(
      completedSessions: _completedFocusSessions,
      totalTime: _totalFocusTimeToday,
    );
  }

  Future<void> initialize() async {
    await loadSettings();
    await loadSessionData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
