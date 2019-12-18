#!/bin/env python
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore

db = None


def init(token_path):
    global db
    cred = credentials.Certificate(token_path)
    firebase_admin.initialize_app(cred)
    db = firestore.client()
