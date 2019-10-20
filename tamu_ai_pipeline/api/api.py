from rest_framework.response import Response
from rest_framework import serializers, viewsets
from rest_framework.views import APIView
import joblib
import pandas as pd
import numpy as np

Model = joblib.load('api/RF_model.pkl')
csvdata = pd.read_csv('api/TestData.csv')

class IncredibleInputSerializer(serializers.Serializer):
    model_input = serializers.CharField()

class ConocoAPIView(APIView):

    def get(self, request):
        # Validate the incoming input (provided through query parameters)
        serializer = IncredibleInputSerializer(data=request.query_params)
        serializer.is_valid(raise_exception=True)

        # Get the model input
        data = serializer.validated_data
        index = data["model_input"]
        x=csvdata.values
        a=np.array([x[int(index),:]])
        
        result = Model.predict_proba(a)
        # Return it in your custom format
        return Response({
            "result": result[0,0],
        })