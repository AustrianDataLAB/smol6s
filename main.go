// These tests use Ginkgo (BDD-style Go testing framework). Refer to
// http://onsi.github.io/ginkgo/ to learn more about Ginkgo.

package main

import (
	"context"
	"os"

	"go.uber.org/zap/zapcore"
	rbacv1 "k8s.io/api/rbac/v1"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/client-go/kubernetes/scheme"
	"sigs.k8s.io/controller-runtime/pkg/client"
	"sigs.k8s.io/controller-runtime/pkg/envtest"
	logf "sigs.k8s.io/controller-runtime/pkg/log"
	"sigs.k8s.io/controller-runtime/pkg/log/zap"
)

var (
	testEnv   *envtest.Environment
	k8sClient client.Client
	ctx       context.Context
	cancel    context.CancelFunc
)

func main() {

	opts := zap.Options{
		Development: true,
		TimeEncoder: zapcore.RFC3339TimeEncoder,
	}
	logf.SetLogger(zap.New(zap.UseFlagOptions(&opts)))

	ctx, cancel = context.WithCancel(context.Background())

	testEnv = &envtest.Environment{
		ErrorIfCRDPathMissing:    false,
		AttachControlPlaneOutput: false,
	}

	testEnv.ControlPlane.GetAPIServer().SecurePort = 7443
	testEnv.ControlPlane.GetAPIServer().CertDir = "/k8s_certs"
	testEnv.ControlPlane.GetAPIServer().SecureServing.Address = "0.0.0.0"

	cfg, err := testEnv.Start()

	if err != nil {
		logf.Log.Error(err, "failed to start k8s manager")
		os.Exit(1)
	}

	k8sClient, _ = client.New(cfg, client.Options{Scheme: scheme.Scheme})

	crb := &rbacv1.ClusterRoleBinding{
		ObjectMeta: metav1.ObjectMeta{
			Name: "crb:openapi-viewer",
		},
		Subjects: []rbacv1.Subject{
			{
				Kind: "Group",
				Name: "system:unauthenticated",
			},
		},
		RoleRef: rbacv1.RoleRef{
			Kind: "ClusterRole",
			Name: "system:discovery",
		},
	}

	if new_err := k8sClient.Create(ctx, crb); new_err != nil {
		logf.Log.Error(new_err, "failed to add crb")
	}

	for err == nil {
		//just needed to have this running
	}

	cancel()
	logf.Log.Error(err, "failed to start k8s")
	os.Exit(1)

}
