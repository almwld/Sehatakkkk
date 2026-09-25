import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'call_sound_coordinator.dart';

typedef NotificationTapHandler = Future<void> Function(String? payload);

enum SehatakNotificationType {
  newMessage,
  appointment,
  medication,
  labResult,
  labRequest,
  payment,
  invoice,
  order,
  promotional,
  system,
  health,
  social,
}

extension SehatakNotificationTypeValue on SehatakNotificationType {
  String get wireValue {
    switch (this) {
      case SehatakNotificationType.newMessage: return 'new_message';
      case SehatakNotificationType.appointment: return 'appointment';
      case SehatakNotificationType.medication: return 'medication';
      case SehatakNotificationType.labResult: return 'lab_result';
      case SehatakNotificationType.labRequest: return 'lab_request';
      case SehatakNotificationType.payment: return 'payment';
      case SehatakNotificationType.invoice: return 'invoice';
      case SehatakNotificationType.order: return 'order';
      case SehatakNotificationType.promotional: return 'promotional';
      case SehatakNotificationType.system: return 'system';
      case SehatakNotificationType.health: return 'health';
      case SehatakNotificationType.social: return 'social';
    }
  }

  static SehatakNotificationType? fromWireValue(String? value) {
    switch (value) {
      case 'new_message':
      case 'message': return SehatakNotificationType.newMessage;
      case 'appointment':
      case 'appointment_confirmed':
      case 'appointment_reminder_24h':
      case 'appointment_reminder_1h':
      case 'appointment_rescheduled':
      case 'appointment_cancelled': return SehatakNotificationType.appointment;
      case 'medication':
      case 'medication_reminder':
      case 'medication_expired':
      case 'medication_refill': return SehatakNotificationType.medication;
      case 'lab_result':
      case 'lab_result_ready':
      case 'lab_reminder': return SehatakNotificationType.labResult;
      case 'lab_request':
      case 'lab_test_request':
      case 'lab_booking_created':
      case 'lab_booking_confirmed': return SehatakNotificationType.labRequest;
      case 'payment':
      case 'payment_success':
      case 'payment_failed':
      case 'payment_refunded':
      case 'balance_added': return SehatakNotificationType.payment;
      case 'invoice':
      case 'invoice_created':
      case 'invoice_paid':
      case 'invoice_due':
      case 'invoice_cancelled': return SehatakNotificationType.invoice;
      case 'order':
      case 'order_confirmed':
      case 'order_preparing':
      case 'order_ready':
      case 'order_on_way':
      case 'order_delivered':
      case 'order_cancelled': return SehatakNotificationType.order;
      case 'promotional': return SehatakNotificationType.promotional;
      case 'system':
      case 'system_update':
      case 'system_maintenance':
      case 'system_feature':
      case 'system_security': return SehatakNotificationType.system;
      case 'health':
      case 'health_water': return SehatakNotificationType.health;
      case 'social': return SehatakNotificationType.social;
      default: return null;
    }
  }
}

