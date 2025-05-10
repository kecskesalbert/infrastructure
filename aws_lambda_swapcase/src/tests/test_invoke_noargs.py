import sys
sys.path.append('.')
from aws_lambda_swapcase.src.lambda_swapcase import lambda_handler

"""
    Return 400 when invoked without parameter
"""
def test_noargs():
    res = lambda_handler({}, {})
    assert res['statusCode'] == '400'
