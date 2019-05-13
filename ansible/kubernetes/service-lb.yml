apiVersion: v1
kind: Service
metadata:
  name: eschool-api
spec:
  ports:
  - name: backend
    port: 8080
    targetPort: 8080
  selector:
    name: eschool-backend
  type: LoadBalancer
  loadBalancerIP: ${static_ip}